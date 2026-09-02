module Dragnet
  module Types
    class Integer < Number
      def decode(value)
        case value
        when /\A\d+\z/
          value.to_i
        when Integer
          value
        else
          result = Integer.try_convert(value)
          return result if result

          raise Type::EncodingError, "Don't know how to decode #{value.inspect} to integer"
        end
      end

      def build_value_from_answer(answer)
        Number::Value.new(answer.integer_value)
      end

      def assign_value(answer, value)
        answer.integer_value = value
      end
    end
  end
end
