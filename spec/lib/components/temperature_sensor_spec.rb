require 'spec_helper'

module Dino
  module Components
    describe TemperatureSensor do
      let(:board) { double(:board, add_analog_hardware: nil, start_read: nil) }
      let(:sensor) { TemperatureSensor.new(board: board, pin: double) }

      it 'should read current value in celsius degrees' do
        sensor.instance_variable_set(:@value, 50)

        expect(sensor.temperature).to eql(-25.5859375)
      end

      it 'should read current value in fahrenheit degrees' do
        sensor.instance_variable_set(:@value, 50)

        expect(sensor.temperature(true)).to eql(-14.0546875)
      end
    end
  end
end
