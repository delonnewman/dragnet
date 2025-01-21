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
          raise "Don't know how to decode #{value.inspect} to #{symbol}"
        end
      end
    end
  end
end
