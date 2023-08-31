# frozen_string_literal: true

module Dragnet
  module Perspectives
    class DataGridSortQuery < Base
      def sort(_question, _scope, _direction, _join_name)
        raise "can't sort questions of type: #{question_type}"
      end

      class Text < self
        def sort(question, scope, direction, join_name)
          if question.settings.long_answer?
            scope.order(Arel.sql("#{join_name}.long_text_value") => direction)
          else
            scope.order(Arel.sql("#{join_name}.short_text_value") => direction)
          end
        end
      end

      class Time < self
        def sort(question, scope, direction, join_name)
          if question.settings.include_date_and_time?
            scope.order(Arel.sql("#{join_name}.date_value") => direction, Arel.sql("#{join_name}.time_value") => direction)
          elsif question.settings.include_time?
            scope.order(Arel.sql("#{join_name}.time_value") => direction)
          else
            scope.order(Arel.sql("#{join_name}.date_value") => direction)
          end
        end
      end

      class Number < self
        def sort(question, scope, direction, join_name)
          if question.settings.decimal?
            scope.order(Arel.sql("#{join_name}.float_value") => direction)
          else
            scope.order(Arel.sql("#{join_name}.integer_value") => direction)
          end
        end
      end

      class Choice < self
        def sort(_question, scope, direction, join_name)
          scope.order(Arel.sql("#{join_name}.question_option_id") => direction)
        end
      end

      class Boolean < self
        def sort(_question, scope, direction, join_name)
          scope.order(Arel.sql("#{join_name}.boolean_value") => direction)
        end
      end
    end
  end
end