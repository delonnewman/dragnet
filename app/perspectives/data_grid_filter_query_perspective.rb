# frozen_string_literal: true

class DataGridFilterQueryPerspective < Perspective
  # TODO: Remove usage of QuestionType#answer_value_fields
  default do
    def filter(_question, _scope, _table, _value)
      raise "can't filter questions of type: #{question_type}"
    end
  end

  for_type :text do
    def filter(_question, scope, table, value)
      # TODO: should test for short or long text
      scope.where.like(table => { short_text_value: "%#{value}%" })
    end
  end

  for_type :time do
    # TODO: should support a date/time range
    def filter(question, scope, table, value)
      if question.settings.include_date?
        scope.where(table => { date_value: value })
      else
        scope.where(table => { time_value: value })
      end
    end
  end

  for_type :number do
    # TODO: should support a number range
    def filter(question, scope, table, value)
      if question.settings.decimal?
        scope.where(table => { float_value: value })
      else
        scope.where(table => { integer_value: value })
      end
    end
  end

  for_type :choice do
    def filter(_question, scope, table, value)
      scope.where(table => { question_option_id: value })
    end
  end

  for_type :boolean do
    def filter(_question, scope, table, value)
      scope.where(table => { boolean_value: value })
    end
  end
end
