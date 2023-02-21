# frozen_string_literal: true

# Behavior for question settings
module Question::Settings
  extend ActiveSupport::Concern

  included do
    serialize :settings
  end

  def countable?
    setting_value(:countable)
  end

  def long_answer?
    setting_value(:long_answer)
  end

  def multiple_answers?
    setting_value(:multiple_answers)
  end

  def include_date?
    setting_value(:include_date)
  end

  def include_time?
    setting_value(:include_time)
  end

  def setting_value(setting)
    default = question_type.setting_default(setting)
    return default unless settings

    settings.fetch(setting, default)
  end
end
