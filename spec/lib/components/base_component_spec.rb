require 'spec_helper'

module Dino
  module Components

    describe BaseComponent do

      it 'should initialize with board and pin' do
        pin = "a pin"
        board = "a board"
        component = BaseComponent.new(pin: pin, board: board)

        expect(component.pin).to eql(pin)
        expect(component.board).to eql(board)
      end

      it 'should assign pins' do
        pins = {red: 'red', green: 'green', blue: 'blue'}
        board = "a board"
        component = BaseComponent.new(pins: pins, board: board)

        expect(component.pins).to eql(pins)
      end

      it 'should require a pin or pins' do
        expect {
          BaseComponent.new(board: 'some board')
        }.to raise_exception /board and pin or pins are required for a component/
      end

      it 'should require a board' do
        expect {
          BaseComponent.new(pin: 'some pin')
        }.to raise_exception /board and pin or pins are required for a component/
      end

      context "when subclassed #after_initialize should be executed" do

        class SpecComponent < BaseComponent

          def successfully_initialized? ; @success ; end

          def options ; @options ; end

          def after_initialize(options={})
            @success = true
            @options = options
          end
        end

        let(:options) { { pin: pin, board: board } }
        let(:pin) { "a pin" }
        let(:board) { "a board" }

        it "should call #after_initialize with options" do
          component = SpecComponent.new(options)
          expect(component).to be_successfully_initialized
          expect(component.options).to eql(options)
        end

      end

    end
  end
end

