# frozen_string_literal: true

class Dragnet::Perspectives::AnswerEvaluation::Number < Dragnet::Perspectives::AnswerEvaluation
  def assign_value!(answer, value)
    return answer.float_value if answer.question.settings.decimal?

    answer.integer_value = value
  end

  def value(answer)
    if answer.question.settings.decimal?
      answer.float_value
    else
      answer.integer_value
    end
  end

  alias number_value value
end
