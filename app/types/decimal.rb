module Dragnet
  module Types
    class Decimal < Number
      def self.decode(value)
        case value
        when /\A\d+\.\d+\z/
          value.to_f
        when Float, Rational
          value
        else
          raise Type::EncodingError, "Don't know how to decode #{value.inspect} to #{symbol}"
        end
      end

      def build_value(answer)
        Number::Value.new(answer.float_value)
      end

      def assign_value(answer, value)
        answer.float_value = value
      end
    end
  end
end
