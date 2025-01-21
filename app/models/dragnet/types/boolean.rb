module Dragnet
  module Types
    class Boolean < Basic
      ignore :do_before_saving_answer

      def self.decode(value)
        value = value.is_a?(String) ? value.downcase : value
        case value
        in true, 'true', '1', 1, 'yes'
          true
        in false, 'false', '0', 0, 'no'
          false
        else
          raise "Don't know how to decode #{value.inspect} into a boolean"
        end
      end
    end
  end
end
