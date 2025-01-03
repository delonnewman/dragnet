# frozen_string_literal: true

module Dragnet
  class DataGrid::Sort < GenericFunction
    # include sql sanitation methods from ActiveRecord
    include ActiveRecord::Sanitization::ClassMethods

    attribute :question
    attribute :scope
    attribute :direction
    attribute :join_name

    def boolean
      scope.order(sanitize_sql_for_order("#{join_name}.boolean_value") => direction)
    end

    def decimal
      scope.order(sanitize_sql_for_order("#{join_name}.float_value") => direction)
    end

    def integer
      scope.order(sanitize_sql_for_order("#{join_name}.integer_value") => direction)
    end

    def text
      scope.order(sanitize_sql_for_order("#{join_name}.short_text_value") => direction)
    end

    def long_text
      scope.order(sanitize_sql_for_order("#{join_name}.long_text_value") => direction)
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
