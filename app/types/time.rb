module Dragnet
  module Types
    class Time < Temporal
      def decode(value)
        super.to_time
      end

      def build_value_from_answer(answer)
        Temporal::Value.new(answer.time_value)
      end

      def assign_value(answer, value)
        answer.time_value = value
      end
    end
  end
end
