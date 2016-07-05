require 'spec_helper'

module Dino
  module Components
    describe Button do
      describe '#initialize' do
        it 'should raise if it does not receive a pin' do
          expect {
            Button.new(board: 'a board')
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should raise if it does not receive a board' do
          expect {
            Button.new(pin: 'a pin')
          }.to raise_exception(/board and pin or pins are required for a component/)
        end

        it 'should add itself to the board and start reading' do
          board = double(:board, add_digital_hardware: nil, start_read: nil)
          Button.new(board: board, pin: 'a pin')

          expect(board).to have_received(:add_digital_hardware)
          expect(board).to have_received(:start_read)
        end
      end

      context 'callbacks' do
        let(:board) { double(:board, add_digital_hardware: true, start_read: true) }
        let(:button) {Button.new(board: board, pin: double)}
        describe '#down' do
          it 'should add a callback to the down_callbacks array' do
            callback = double(called: nil)
            button.down do
              callback.called
            end
            down_callbacks = button.instance_variable_get(:@down_callbacks)
            expect(down_callbacks.size).to eql(1)
            down_callbacks.first.call

            expect(callback).to have_received(:called)
          end
        end

        describe '#up' do
          it 'should add a callback to the up_callbacks array' do
            callback = double(called: nil)
            button.up do 
              callback.called
            end
            up_callbacks = button.instance_variable_get(:@up_callbacks)
            expect(up_callbacks.size).to eql(1)
            up_callbacks.first.call

            expect(callback).to have_received(:called)
          end
        end

        describe '#update' do
          it 'should call the down callbacks' do
            callback_1 = double(called: nil)
            button.down do 
              callback_1.called
            end
            
            callback_2 = double(called: nil)
            button.down do 
              callback_2.called
            end

            button.update(Button::DOWN)

            expect(callback_1).to have_received(:called)
            expect(callback_2).to have_received(:called)
          end

          it 'should call the up callbacks' do
            callback_1 = double(called: nil)
            button.up do
              callback_1.called
            end
            
            callback_2 = double(called: nil)
            button.up do 
              callback_2.called
            end

            button.instance_variable_set(:@state, Button::DOWN)
            button.update(Button::UP)

            expect(callback_1).to have_received(:called)
            expect(callback_2).to have_received(:called)
          end

          it 'should not call the callbacks if the state has not changed' do
            callback = double(called: nil)
            button.up do
              callback.called
            end

            button.update(Button::UP)
            button.update(Button::UP)

            expect(callback).to_not have_received(:called)
          end

          it 'should not call the callbacks if the data is not UP or DOWN' do
            callback_1 = double(called: nil)
            button.up do 
              callback_1.called
            end

            callback_2 = double(called: nil)
            button.down do 
              callback_2.called
            end

            button.update('foobarred')

            expect(callback_1).to_not have_received(:called)
            expect(callback_2).to_not have_received(:called)
          end
        end
      end
    end
  end
end
