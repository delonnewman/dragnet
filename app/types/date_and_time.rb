module Dragnet
  module Types
    class DateAndTime < Temporal
      def decode(value)
        super(value).to_time
      end

      def build_value_from_answer(answer)
        date = answer.date_value
        time = answer.time_value
        value = DateTime.new(
          date.year, date.month, date.day,
          time.hour, time.min, time.sec, time.utc_offset
        )
        Temporal::Value.new(value)
      end

      def assign_value(answer, value)
        answer.time_value = value.to_time
        answer.date_value = value.to_date
      end
    end
  end
end
