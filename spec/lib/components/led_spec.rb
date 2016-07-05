require 'spec_helper'

module Dino
  module Components
    describe Led do
      let(:board) { double(:board, digital_write: true, set_pin_mode: true) }

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Led.new(board: board)
          }.to raise_exception /board and pin or pins are required for a component/
        end

        it 'should raise if it does not receive a board' do
          expect {
            Led.new(pins: {})
          }.to raise_exception /board and pin or pins are required for a component/
        end

        it 'should set the pin to out' do
          Led.new(pin: 13, board: board)
          expect(board).to have_received(:set_pin_mode).with(13, :out, nil)
        end

        it 'should set the pin to low' do
          Led.new(pin: 13, board: board)
          expect(board).to have_received(:digital_write).with(13, Board::LOW)
        end
      end

      describe '#on' do
        it 'should send a high to the board with the pin' do
          @led = Led.new(pin: 13, board: board)
          @led.on
          expect(board).to have_received(:digital_write).with(13, Board::HIGH)
        end
      end

      describe '#off' do
        it 'should send a high to the board with the pin' do
          @led = Led.new(pin: 13, board: board)
          @led.off
          expect(board).to have_received(:digital_write).with(13, Board::LOW).twice
        end
      end

      describe '#blink' do
        it 'should turn the led off if it is on'
        it 'should not block'
      end
    end
  end
end
