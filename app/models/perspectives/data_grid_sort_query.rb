# frozen_string_literal: true

module Perspectives
  class DataGridSortQuery < BasePerspective
    class Default < self
      def sort(_question, _scope, _direction)
        raise "can't sort questions of type: #{question_type}"
      end
    end

    class Text < self
      def sort(question, scope, direction)
        if question.settings.long_answer?
          scope.order(long_text_value: direction)
        else
          scope.order(short_text_value: direction)
        end
      end
    end

    class Time < self
      def sort(question, scope, direction)
        if question.settings.include_date_and_time?
          scope.order(date_value: direction, time_value: direction)
        elsif question.settings.include_time?
          scope.order(time_value: direction)
        else
          scope.order(date_value: direction)
        end
      end
    end

    class Number < self
      def sort(question, scope, direction)
        if question.settings.decimal?
          scope.order(float_value: direction)
        else
          scope.order(integer_value: direction)
        end
      end
    end

    class Choice < self
      def sort(_question, scope, direction)
        scope.order(question_option_id: direction)
      end
    end

    class Boolean < self
      def sort(_question, scope, direction)
        scope.order(boolean_value: direction)
      end
    end
  end
end
