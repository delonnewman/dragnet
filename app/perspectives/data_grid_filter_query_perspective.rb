# frozen_string_literal: true

class DataGridFilterQueryPerspective < ApplicationPerspective
  context :default do
    def render(scope, value)
      scope.where.like(answers: { question_type.answer_value_field => "%#{value}%" })
    end
  end
end
