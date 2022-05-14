class QuestionOptions < ApplicationRecord
  belongs_to :question

  has_one :followup_question, class_name: 'Question'
end
