class QuestionOption < ApplicationRecord
  belongs_to :question

  validates :text, presence: true

  has_many :followup_questions, class_name: 'Question'
  accepts_nested_attributes_for :followup_questions

  def to_s
    text
  end
end
