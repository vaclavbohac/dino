require 'spec_helper'

module Dino
  module Components
    describe RgbLed do
      let(:board) { double(:board, analog_write: true, set_pin_mode: true) }
      let(:pins) { {red: 1, green: 2, blue: 3} }
      let(:rgb) { RgbLed.new(pins: pins, board: board)}

      def expect_levels(*levels)
        levels.each_with_index do |level, i|
          expect(board).to have_received(:analog_write).with(i + 1, level).at_least(:once)
        end
      end

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            RgbLed.new(board: 'a board')
          }.to raise_exception /board and pin or pins are required for a component/
        end

        it 'should raise if it does not receive a board' do
          expect {
            RgbLed.new(pins: pins)
          }.to raise_exception /board and pin or pins are required for a component/
        end

        it 'should set the pin to out' do
          RgbLed.new(pins: pins, board: board)

          expect(board).to have_received(:set_pin_mode).with(1, :out, nil)
          expect(board).to have_received(:set_pin_mode).with(2, :out, nil)
          expect(board).to have_received(:set_pin_mode).with(3, :out, nil)
        end

        it 'should set the pin to low' do
          RgbLed.new(pins: pins, board: board)

          expect_levels(Board::LOW, Board::LOW, Board::LOW)
        end
      end

      describe '#red' do
        it 'should set red to high, blue and green to low' do
          rgb.red

          expect_levels(Board::HIGH, Board::LOW, Board::LOW)
        end
      end

      describe '#green' do
        it 'should set green to high, red and blue to low' do
          rgb.green

          expect_levels(Board::LOW, Board::HIGH, Board::LOW)
        end
      end

      describe '#blue' do
        it 'should set blue to high, red and green to low' do
          rgb.blue

          expect_levels(Board::LOW, Board::LOW, Board::HIGH)
        end
      end

      describe '#cyan' do
        it 'should set blue and green to high, red to low' do
          rgb.cyan

          expect_levels(Board::LOW, Board::HIGH, Board::HIGH)
        end
      end

      describe '#yellow' do
        it 'should set red and green to high, blue to low' do
          rgb.yellow

          expect_levels(Board::HIGH, Board::HIGH, Board::LOW)
        end
      end

      describe '#magenta' do
        it 'should set red and blue to high, green to low' do
          rgb.magenta

          expect_levels(Board::HIGH, Board::LOW, Board::HIGH)
        end
      end

      describe '#white' do
        it 'should set all to high' do
          rgb.white

          expect_levels(Board::HIGH, Board::HIGH, Board::HIGH)
        end
      end

      describe '#off' do
        it 'should set all to low' do
          rgb.off

          expect_levels(Board::LOW, Board::LOW, Board::LOW)
        end
      end

      describe '#blinky' do
        it 'should set blue to high, red and green to low' do
          allow_any_instance_of(Array).to receive(:cycle).and_yield(:red).and_yield(:green).and_yield(:blue)
          expect_any_instance_of(RgbLed).to receive(:red)
          expect_any_instance_of(RgbLed).to receive(:green)
          expect_any_instance_of(RgbLed).to receive(:blue)
          rgb.blinky
        end
      end
    end
  end
end
