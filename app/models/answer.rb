class Answer < ApplicationRecord
  belongs_to :survey
  belongs_to :reply
  belongs_to :question

  def value=(value)
    case question.question_type
    when :short_answer
      self.short_text_value = value
    when :paragraph
      self.long_text_value = value
    when :multiple_choice, :checkboxes
      self.question_option = value
    end
  end
end
