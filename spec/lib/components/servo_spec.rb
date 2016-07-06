require 'spec_helper'

RSpec.configure do |c|
  c.raise_errors_for_deprecations!
end

module Dino
  module Components
    describe Servo do
      let(:board) { double(:board, analog_write: true, set_pin_mode: true, servo_toggle: true, servo_write: true) }

      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Servo.new(board: board)
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should raise if it does not receive a board' do
          expect {
            Servo.new(pin: 13)
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should set the pins to out' do
          Servo.new(pin: 13, board: board)
          expect(board).to have_received(:set_pin_mode).with(13, :out, nil)
        end

        it 'should set the inital position to 0' do
          servo =  Servo.new(pin: 13, board: board)
          expect(servo.instance_variable_get(:@position)).to eql(0)
        end
      end

      describe '#position' do
        let(:servo) { Servo.new(pin: 13, board: board) }

        it 'should set the position of the Servo' do
          servo.position = 90
          expect(servo.instance_variable_get(:@position)).to eql(90)
        end

        it 'should let you write up to 180' do
          servo.position = 180
          expect(servo.instance_variable_get(:@position)).to eql(180)
        end

        it 'should modulate when position > 180' do
          servo.position = 190
          expect(servo.instance_variable_get(:@position)).to eql(10)
        end

        it 'should write the new position to the board' do
          servo.position = 190
          expect(board).to have_received(:servo_write).with(13, 10)
        end
      end
    end
  end
end

