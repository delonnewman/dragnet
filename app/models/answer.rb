class Answer < ApplicationRecord
  belongs_to :survey
  belongs_to :reply
  belongs_to :question

  # for question_option values
  belongs_to :question_option, optional: true
  with Answer::Evalutation, delegating: %i[value value= to_s to_i to_f blank?]

  belongs_to :question_type
  after_initialize do
    self.question_type = question.question_type if question
  end
end
