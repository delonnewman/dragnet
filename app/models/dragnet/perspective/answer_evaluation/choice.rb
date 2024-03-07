# frozen_string_literal: true

class Dragnet::Perspective::AnswerEvaluation::Choice < Dragnet::Perspective::AnswerEvaluation
  def assign_value!(answer, value)
    answer.question_option_id = value
  end

  def value(answer)
    answer.question_option&.text
  end

  def number_value(answer)
    answer.question_option&.weight
  end
end
