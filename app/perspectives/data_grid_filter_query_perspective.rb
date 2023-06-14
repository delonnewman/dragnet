# frozen_string_literal: true

class DataGridFilterQueryPerspective < Perspective
  # TODO: Remove usage of QuestionType#answer_value_fields
  default do
    def filter(_question, _scope, _value)
      raise "can't filter questions of type: #{question_type}"
    end
  end

  for_type :text do
    def filter(_question, scope, value)
      # TODO: should test for short or long text
      scope.where.like(answers: { short_text_value: "%#{value}%" })
    end
  end

  for_type :time do
    # TODO: should support a date range, should test for time only and use the time_value field
    def filter(_question, scope, value)
      scope.where(answers: { date_value: value })
    end
  end

  for_type :number do
    # TODO: should support a number range
    def filter(_question, scope, value)
      # TODO: should test for whether it's a decimal or float and use the appropriate attribute
      scope.where(answers: { number_value: value })
    end
  end

  for_type :choice do
    def filter(_question, scope, value)
      scope.where(answers: { question_option_id: value })
    end
  end

  for_type :boolean do
    def filter(_question, scope, value)
      scope.where(answers: { boolean_value: value })
    end
  end
end
