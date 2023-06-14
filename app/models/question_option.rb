class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :text, presence: true

  # TODO: Remove followup questions
  has_many :followup_questions, class_name: 'Question', dependent: :delete_all, inverse_of: :question_option
  accepts_nested_attributes_for :followup_questions

  def to_s
    text
  end
end
