class Answer < ApplicationRecord
  belongs_to :survey
  belongs_to :reply
  belongs_to :question

  # for question_option values
  belongs_to :question_option, optional: true
  belongs_to :question_type

  before_validation do
    self.question_type = question.question_type if question
  end

  def to_s
    value.to_s
  end

  def blank?
    value.blank?
  end

  def value=(value)
    case question_type.ident
    when :short_answer
      self.short_text_value = value
    when :paragraph
      self.long_text_value = value
    when :multiple_choice, :checkboxes
      self.question_option = value
    end
  end

  def text_value
    case question_type.ident
    when :short_answer
      short_text_value
    when :paragraph
      long_text_value
    when :multiple_choice, :checkboxes
      question_option&.text
    end
  end
  alias value text_value

  def number_value
    case question_type.ident
    when :multiple_choice, :checkboxes
      question_option&.weight
    end
  end
end
