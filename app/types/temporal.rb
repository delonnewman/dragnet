module Dragnet
  module Types
    class Temporal < Basic
      def do_before_saving_answer(...) = DoNothing.new

      def decode(value)
        case value
        when String
          ::DateTime.parse(value)
        when ::Date, ::Time, ::DateTime
          value
        else
          raise Type::EncodingError, "Don't know how to decode #{value.inspect} to #{symbol}"
        end
      end
    end
  end
end
