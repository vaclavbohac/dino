module Dino
  module Components
    class Stepper < BaseComponent

      def after_initialize(*)
        raise 'missing pins[:step] pin' unless self.pins[:step]
        raise 'missing pins[:direction] pin' unless self.pins[:direction]

        set_pin_mode(pins[:step], :out)
        set_pin_mode(pins[:direction], :out)
        digital_write(pins[:step], Board::LOW)
      end

      def step_cc
        step(Board::HIGH, Board::HIGH, Board::LOW)
      end

      def step_cw
        step(Board::LOW, Board::HIGH, Board::LOW)
      end

      private

      def step(direction, *steps)
        digital_write(self.pins[:direction], direction)
        steps.each do |step|
            digital_write(self.pins[:step], step)
        end
      end
    end
  end
end
