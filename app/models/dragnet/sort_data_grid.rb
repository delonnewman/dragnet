# frozen_string_literal: true

module Dragnet
  class SortDataGrid < GenericFunction
    # include sql sanitation methods from ActiveRecord
    include ActiveRecord::Sanitization::ClassMethods

    attribute :question
    attribute :scope
    attribute :direction
    attribute :join_name

    def boolean
      scope.order(sanitize_sql_for_order("#{join_name}.boolean_value") => direction)
    end

    def number
      if question.settings.decimal?
        scope.order(sanitize_sql_for_order("#{join_name}.float_value") => direction)
      else
        scope.order(sanitize_sql_for_order("#{join_name}.integer_value") => direction)
      end
    end

    def text
      if question.settings.long_answer?
        scope.order(sanitize_sql_for_order("#{join_name}.long_text_value") => direction)
      else
        scope.order(sanitize_sql_for_order("#{join_name}.short_text_value") => direction)
      end
    end

    def time
      scope.order(sanitize_sql_for_order("#{join_name}.time_value") => direction)
    end

    def date_and_time
      scope.order(
        sanitize_sql_for_order("#{join_name}.date_value") => direction,
        sanitize_sql_for_order("#{join_name}.time_value") => direction
      )
    end

    def date
      scope.order(sanitize_sql_for_order("#{join_name}.date_value") => direction)
    end

    def choice
      scope.order(sanitize_sql_for_order("#{join_name}.question_option_id") => direction)
    end
  end
end
