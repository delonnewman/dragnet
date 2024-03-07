# frozen_string_literal: true

class Dragnet::Perspective::AnswerEvaluation::Boolean < Dragnet::Perspective::AnswerEvaluation
  def assign_value!(answer, value)
    answer.boolean_value = value
  end

  def value(answer)
    answer.boolean_value
  end
end
