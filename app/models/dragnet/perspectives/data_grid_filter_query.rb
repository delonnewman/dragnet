# frozen_string_literal: true

module Dragnet
  module Perspectives
    class DataGridFilterQuery < Base
      def filter(_question, _scope, _table, _value)
        raise "can't filter questions of type: #{question_type}"
      end

      class Text < self
        def filter(question, scope, table, value)
          if question.settings.long_answer?
            scope.where.like(table => { long_text_value: "%#{value}%" })
          else
            scope.where.like(table => { short_text_value: "%#{value}%" })
          end
        end
      end

      class Time < self
        # TODO: should support a date/time range
        def filter(question, scope, table, value)
          if question.settings.include_date?
            scope.where(table => { date_value: value })
          else
            scope.where(table => { time_value: value })
          end
        end
      end

      class Number < self
        # TODO: should support a number range
        def filter(question, scope, table, value)
          if question.settings.decimal?
            scope.where(table => { float_value: value })
          else
            scope.where(table => { integer_value: value })
          end
        end
      end

      class Choice < self
        def filter(_question, scope, table, value)
          scope.where(table => { question_option_id: value })
        end
      end

      class Boolean < self
        def filter(_question, scope, table, value)
          scope.where(table => { boolean_value: value })
        end
      end
    end
  end
end