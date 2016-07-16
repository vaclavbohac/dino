module Dino
  module Components
    attr_reader :value

    # Works well with TMP36 - http://ardx.org/datasheet/IC-TMP36.pdf

    class TemperatureSensor < Sensor
      VOLTS_PER_UNIT = 5 / 1024.0

      def to_voltage(digital)
        digital * VOLTS_PER_UNIT
      end

      def to_celsius(voltage)
        (voltage - 0.5) * 100
      end

      def to_fahrenheit(voltage)
        to_celsius(voltage) * 1.8 + 32
      end

      def temperature(fahrenheit = false)
        voltage = to_voltage self.value.to_f

        if fahrenheit
          to_fahrenheit voltage
        else
          to_celsius voltage
        end
      end
    end
  end
end
