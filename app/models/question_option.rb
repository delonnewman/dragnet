class QuestionOption < ApplicationRecord
  belongs_to :question

  has_many :followup_questions, class_name: 'Question'
  accepts_nested_attributes_for :followup_question
end
