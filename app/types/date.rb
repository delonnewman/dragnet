module Dragnet
  module Types
    class Date < Temporal
      def self.decode(value)
        super(value).to_date
      end

      def build_value(answer)
        Temporal::Value.new(answer.date_value)
      end

      def assign_value(answer, value)
        answer.date_value = value
      end
    end
  end
end
