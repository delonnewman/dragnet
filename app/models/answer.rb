class Answer < ApplicationRecord
  belongs_to :survey
  belongs_to :reply
  belongs_to :question

  # for question_option values
  belongs_to :question_option, optional: true

  # TODO: Cache this
  def question_type
    question.question_type
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

  def value
    case question_type.ident
    when :short_answer
      short_text_value
    when :paragraph
      long_text_value
    when :multiple_choice, :checkboxes
      question_option
    end
  end

  def to_s
    value.to_s
  end
end
