module Dragnet
  module Types
    class Integer < Number
      def self.decode(value)
        case value
        when /\A\d+\z/
          value.to_i
        when Integer
          value
        else
          result = Integer.try_convert(value)
          return result if result

          raise "Don't know how to decode #{value.inspect} to integer"
        end
      end

      def self.encode(value)
        value.to_s
      end
    end
  end
end
