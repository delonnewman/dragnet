module Dragnet
  module Types
    class Temporal < Basic
      ignore :do_before_saving_answer

      def self.decode(value)
        case value
        when String
          ::DateTime.parse(value)
        when ::Date, ::Time, ::DateTime
          value
        else
          raise "Don't know how to decode #{value.inspect} to #{tag}"
        end
      end
    end
  end
end
