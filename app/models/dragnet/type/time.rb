# frozen_string_literal: true

module Dragnet
  class Type::Time < Type
    def data_grid_sort(question, scope, direction, join_name)
      if question.settings.include_date_and_time?
        scope.order(
          sanitize_sql_for_order("#{join_name}.date_value") => direction,
          sanitize_sql_for_order("#{join_name}.time_value") => direction
        )
      elsif question.settings.include_time?
        scope.order(sanitize_sql_for_order("#{join_name}.time_value") => direction)
      else
        scope.order(sanitize_sql_for_order("#{join_name}.date_value") => direction)
      end
    end

    # TODO: should support a date/time range
    def data_grid_filter(question, scope, table, value)
      if question.settings.include_date?
        scope.where(table => { date_value: value })
      else
        scope.where(table => { time_value: value })
      end
    end

    def assign_value!(answer, value)
      answer.time_value = value if answer.question.settings.include_time?
      answer.date_value = value if answer.question.settings.include_date?
    end

    def value(answer)
      question = answer.question
      date = answer.date_value
      time = answer.time_value

      if date && time && question.settings.include_date_and_time?
        DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.utc_offset)
      end

      return date if date && question.settings.include_date?

      time
    end

    def number_value(answer)
      value(answer)&.to_i
    end
  end
end
