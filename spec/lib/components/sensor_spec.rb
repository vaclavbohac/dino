require 'spec_helper'

module Dino
  module Components
    describe Sensor do

      let(:board){double(:board).as_null_object}

      describe '#initalize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Sensor.new(board: 'a board')
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should raise if it does not receive a board' do
          expect {
            Sensor.new(pin: 'a pin')
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should add itself to the board and start reading' do
          Sensor.new(board: board, pin: 'a pin')
          expect(board).to have_received(:add_analog_hardware)
          expect(board).to have_received(:start_read)
        end

        it 'should initalize data_callbacks' do
          sensor = Sensor.new(board: board, pin: 'a pin')
          expect(sensor.instance_variable_get(:@data_callbacks)).to eql([])
        end

        it 'should initialize value' do
          sensor = Sensor.new(board: board, pin: 'a pin')
          expect(sensor.value).to eql(0)
        end
      end

      describe '#when_data_received' do
        it "should add a callback to the list of callbacks" do
          sensor = Sensor.new(board: board, pin: 'a pin')
          sensor.when_data_received { "this is a block" }
          expect(sensor.instance_variable_get(:@data_callbacks)).to_not be_empty
        end
      end

      describe '#update' do
        it 'should call all callbacks passing in the given data' do
          sensor = Sensor.new(board: board, pin: 'a pin')

          first_block_data = nil
          second_block_data = nil
          sensor.when_data_received do |data|
            first_block_data = data
          end
          sensor.when_data_received do |data|
            second_block_data = data
          end

          sensor.update('Some data')
          [first_block_data, second_block_data].each do |block_data|
            expect(block_data).to eql('Some data')
          end
        end

        it 'should update the value' do
          sensor = Sensor.new(board: board, pin: 'a pin')

          sensor.update('Some data')
          expect(sensor.value).to eql('Some data')
        end
      end
    end
  end
end
