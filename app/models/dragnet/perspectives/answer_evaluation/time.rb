# frozen_string_literal: true

class Dragnet::Perspectives::AnswerEvaluation::Time < Dragnet::Perspectives::AnswerEvaluation
  def assign_value!(answer, value)
    answer.time_value = value if answer.question.settings.include_time?
    answer.date_value = value if answer.question.settings.include_date?
  end

  def value(answer)
    question = answer.question
    date_time = question.settings.include_date_and_time?
    return answer.date_value if !date_time && question.settings.include_date?
    return answer.time_value if !date_time && question.settings.include_time?

    d = answer.date_value
    t = answer.time_value
    DateTime.new(d.year, d.month, d.day, t.hour, t.min, t.sec, t.utc_offset)
  end

  def number_value(answer)
    value(answer)&.to_i
  end
end
