# frozen_string_literal: true

class Question::Settings < Dragnet::Advice
  advises Question

  def countable?
    setting?(:countable)
  end

  def long_answer?
    setting?(:long_answer)
  end

  def multiple_answers?
    setting?(:multiple_answers)
  end

  def include_date_and_time?
    include_date? && include_time?
  end

  def include_date?
    setting?(:include_date)
  end

  def include_time?
    setting?(:include_time)
  end

  def integer?
    !decimal?
  end

  def decimal?
    setting?(:decimal)
  end

  def setting?(setting)
    !!setting(setting)
  end

  def setting(setting)
    default = question.question_type.setting_default(setting)
    return default unless question.config

    question.config.fetch(setting, default)
  end
end
