# frozen_string_literal: true

class DataGridFilterQueryPerspective < Perspective
  default do
    def filter(scope, value)
      scope.where(answers: { question_type.answer_value_field => value })
    end
  end

  for_type :text do
    def filter(scope, value)
      scope.where.like(answers: { question_type.answer_value_field => "%#{value}%" })
    end
  end

  # TODO: need to make time types use Answer#time_value
  for_type :time do
    def filter(scope, value)
      scope.where(answers: { question_type.answer_value_field => value })
    end
  end
end
