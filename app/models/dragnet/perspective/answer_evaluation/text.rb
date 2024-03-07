# frozen_string_literal: true

class Dragnet::Perspective::AnswerEvaluation::Text < Dragnet::Perspective::AnswerEvaluation
  def assign_value!(answer, value)
    if answer.question.settings.long_answer?
      answer.long_text_value = value
    else
      answer.short_text_value = value
    end
  end

  def value(answer)
    return answer.long_text_value if answer.question.settings.long_answer?

    answer.short_text_value
  end

  alias sort_value value
end
