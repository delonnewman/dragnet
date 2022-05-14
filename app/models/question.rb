class Question < ApplicationRecord
  belongs_to :survey
  belongs_to :question_type

  has_many :question_options
  has_many :followup_questions
end
