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
    when :text
      if question.long_answer?
        self.long_text_value = value
      else
        self.short_text_value = value
      end
    when :choice
      self.question_option = value
    when :number
      self.number_value = value
    end
  end

  def text_value
    case question_type.ident
    when :text
      if question.long_answer?
        long_text_value
      else
        short_text_value
      end
    when :choice
      question_option&.text
    end
  end
  alias value text_value

  def number_value
    case question_type.ident
    when :choice
      question_option&.weight
    when :number
      number_value
    end
  end
end
