require 'spec_helper'

module Dino
  describe Dino::Board do
    def io_mock(methods = {})
      props = {
          write: nil,
          add_observer: nil,
          close_read: nil,
          flush_read: nil,
          read: nil,
          handshake: '14'
      }.merge(methods)

      @io ||= double(:io, props)
    end

    subject { Board.new(io_mock) }

    describe '#initialize' do
      it 'should take an io class' do
        expect {
          Board.new(io_mock)
        }.to_not raise_exception
      end

      it 'should observe the io' do
        expect(io_mock).to have_received(:add_observer).with(subject)
      end

      it 'should initiate the handshake' do
        subject

        expect(io_mock).to have_received(:handshake)
      end
    end

    describe '#update' do
      context 'when the given pin connects to an analog hardware part' do
        it 'should call update with the message on the part' do
          part = double(:part, pin: 7, update: nil)
          subject.add_analog_hardware(part)
          other_part = double(:part, pin: 9, update: nil)
          subject.add_analog_hardware(other_part)

          subject.update(7, 'wake up!')
          expect(part).to have_received(:update).with('wake up!')
        end
      end

      context 'when the given pin connects to an digital hardware part' do
        it 'should call update with the message on the part' do
          part = double(:part, pin: 5, pullup: nil, update: nil)
          subject.add_digital_hardware(part)
          other_part = double(:part, pin: 11, pullup: nil, update: nil)
          subject.add_digital_hardware(other_part)

          subject.update(5, 'wake up!')
          expect(part).to have_received(:update).with('wake up!')
          expect(other_part).to_not have_received(:update).with('wake up!')
        end
      end

      context 'when the given pin is not connected' do
        it 'should not do anything' do
          expect {
            subject.update(5, 'wake up!')
          }.to_not raise_exception
        end
      end
    end

    describe '#digital_hardware' do
      it 'should initialize as empty' do
        expect(subject.digital_hardware).to eql([])
      end
    end

    describe '#analog_hardware' do
      it 'should initialize as empty' do
        expect(subject.analog_hardware).to eql([])
      end
    end

    describe '#add_digital_hardware' do
      it 'should add digital hardware to the board' do
        subject.add_digital_hardware(mock1 = double(:part1, pin: 12, pullup: nil))
        subject.add_digital_hardware(mock2 = double(:part2, pin: 14, pullup: nil))
        expect(subject.digital_hardware).to eq([mock1, mock2])
      end

      it 'should set the mode for the given pin to "in" and add a digital listener' do
        subject.add_digital_hardware(mock1 = double(:part1, pin: 12, pullup: nil, write: nil))

        expect(io_mock).to have_received(:write).with('!0012001.')
        expect(io_mock).to have_received(:write).with('!0112000.')
        expect(io_mock).to have_received(:write).with('!0512000.')
      end
    end

    describe '#remove_digital_hardware' do
      it 'should remove the given part from the hardware of the board' do
        double = double(:part1, pin: 12, pullup: nil)
        subject.add_digital_hardware(double)
        subject.remove_digital_hardware(double)
        expect(subject.digital_hardware).to eq([])
      end
    end

    describe '#add_analog_hardware' do
      it 'should add analog hardware to the board' do
        subject.add_analog_hardware(mock1 = double(:part1, pin: 12, pullup: nil))
        subject.add_analog_hardware(mock2 = double(:part2, pin: 14, pullup: nil))
        expect(subject.analog_hardware).to eq([mock1, mock2])
      end

      it 'should set the mode for the given pin to "in" and add an analog listener' do
        subject.add_analog_hardware(mock1 = double(:part1, pin: 12, pullup: nil))

        expect(io_mock).to have_received(:write).with('!0012001.')
        expect(io_mock).to have_received(:write).with('!0112000.')
        expect(io_mock).to have_received(:write).with('!0612000.')
      end
    end

    describe '#remove_analog_hardware' do
      it 'should remove the given part from the hardware of the board' do
        double = double(:part1, pin: 12, pullup: nil)
        subject.add_analog_hardware(double)
        subject.remove_analog_hardware(double)
        expect(subject.analog_hardware).to eq([])
      end
    end

    describe '#start_read' do
      it 'should tell the io to read' do
        subject.start_read

        expect(io_mock).to have_received(:read)
      end
    end

    describe '#stop_read' do
      it 'should tell the io to read' do
        subject.stop_read

        expect(io_mock).to have_received(:close_read)
      end
    end

    describe '#write' do
      it 'should return true if the write succeeds' do
        @io = nil
        board = Board.new(io_mock(write: true))
        expect(board.write('message')).to eq(true)
      end

      it 'should wrap the message in a ! and a . by default' do
        subject.write('hello')

        expect(io_mock).to have_received(:write).with('!hello.')
      end

      it 'should not wrap the message if no_wrap is set to true' do
        subject.write('hello', no_wrap: true)

        expect(io_mock).to have_received(:write).with('hello')
      end
    end

    describe '#digital_write' do
      it 'should append a append a write to the pin and value' do
        subject.digital_write(01, 003)

        expect(io_mock).to have_received(:write).with('!0101003.')
      end
    end

    describe '#digital_read' do
      it 'should tell the board to read once from the given pin' do
        subject.digital_read(13)

        expect(io_mock).to have_received(:write).with('!0213000.')
      end
    end

    describe '#analog_write' do
      it 'should append a append a write to the pin and value' do
        subject.analog_write(01, 003)

        expect(io_mock).to have_received(:write).with('!0301003.')
      end
    end

    describe '#analog_read' do
      it 'should tell the board to read once from the given pin' do
        subject.analog_read(13)

        expect(io_mock).to have_received(:write).with('!0413000.')
      end
    end

    describe '#digital_listen' do
      it 'should tell the board to continuously read from the given pin' do
        subject.digital_listen(13)

        expect(io_mock).to have_received(:write).with('!0513000.')
      end
    end

    describe '#analog_listen' do
      it 'should tell the board to continuously read from the given pin' do
        subject.analog_listen(13)

        expect(io_mock).to have_received(:write).with('!0613000.')
      end
    end

    describe '#stop_listener' do
      it 'should tell the board to stop sending values for the given pin' do
        subject.stop_listener(13)

        expect(io_mock).to have_received(:write).with('!0713000.')
      end
    end

    describe '#set_pin_mode' do
      it 'should send a value of 0 if the pin mode is set to out' do
        subject.set_pin_mode(13, :out)

        expect(io_mock).to have_received(:write).with('!0013000.')
      end

      it 'should send a value of 1 if the pin mode is set to in' do
        subject.set_pin_mode(13, :in)

        expect(io_mock).to have_received(:write).with('!0013001.')
      end
    end

    describe '#handshake' do
      it 'should tell the board to reset to defaults' do
        subject.handshake

        expect(io_mock).to have_received(:handshake).twice
      end
    end

    describe '#normalize_pin' do
      it 'should normalize numbers so they are two digits' do
        expect(subject.normalize_pin(1)).to eq('01')
      end

      it 'should not normalize numbers that are already two digits' do
        expect(subject.normalize_pin(10)).to eq('10')
      end

      it 'should raise if a number larger than two digits are given' do
        expect { subject.normalize_pin(1000) }.to raise_exception 'pin number must be in 0-99'
      end
    end

    describe '#normalize_value' do
      it 'should normalize numbers so they are three digits' do
        expect(subject.normalize_value(1)).to eql('001')
      end

      it 'should not normalize numbers that are already three digits' do
        expect(subject.normalize_value(10)).to eql('010')
      end

      it 'should raise if a number larger than three digits are given' do
        expect { subject.normalize_value(1000) }.to raise_exception 'values are limited to three digits'
      end
    end
  end
end
