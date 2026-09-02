module Dragnet
  module Types
    class Boolean < Basic
      def do_before_saving_answer(...) = DoNothing.new

      def self.decode(value)
        value = value.is_a?(String) ? value.downcase : value
        case value
        in true, 'true', '1', 1, 'yes'
          true
        in false, 'false', '0', 0, 'no'
          false
        else
          raise Type::EncodingError, "Don't know how to decode #{value.inspect} into a boolean"
        end
      end

      def build_value_from_answer(answer)
        Value.new(answer.boolean_value)
      end

      def assign_value(answer, value)
        answer.boolean_value = !!value
      end
    end
  end
end
