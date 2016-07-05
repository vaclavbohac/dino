require 'spec_helper'

module Dino
  module Components
    describe Stepper do
      let(:board) { double(:board, digital_write: true, set_pin_mode: true) }

      describe '#initialize' do
        it 'should raise if it does not receive a step pin' do
          expect {
            Stepper.new(board: board)
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should raise if it does not receive a direction pin' do
          expect {
            Stepper.new(board: board)
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should raise if it does not receive a board' do
          expect {
            Stepper.new(pins: {step: 12, direction: 13})
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should set the pins to out' do
          Stepper.new(pins: {step: 13, direction: 12}, board: board)
          expect(board).to have_received(:set_pin_mode).with(13, :out, nil)
          expect(board).to have_received(:set_pin_mode).with(12, :out, nil)
        end

        it 'should set the step pin to low' do
          Stepper.new(pins: {step: 13, direction: 12}, board: board)
          expect(board).to have_received(:digital_write).with(13, Board::LOW)
        end
      end

      describe '#step_cc' do
        it 'should send a high to the board with the pin' do
          @stepper = Stepper.new(pins: {step: 13, direction: 12}, board: board)
          @stepper.step_cc
          expect(board).to have_received(:digital_write).with(12, Board::HIGH)
          expect(board).to have_received(:digital_write).with(13, Board::HIGH)
          expect(board).to have_received(:digital_write).with(13, Board::LOW).twice
        end
      end

      describe '#step_cw' do
        it 'should send a high to the board with the pin' do
          @stepper = Stepper.new(pins: {step: 13, direction: 12}, board: board)
          @stepper.step_cw
          expect(board).to have_received(:digital_write).with(12, Board::LOW)
          expect(board).to have_received(:digital_write).with(13, Board::HIGH)
          expect(board).to have_received(:digital_write).with(13, Board::LOW).twice
        end
      end
    end
  end
end
