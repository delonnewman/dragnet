# TODO: add timestamped states (i.e. created, submitted)
# they should only become visible for reporting when in the "submitted" state
# and "submitted_at" timestamp should be used for reporting purposes
class Reply < ApplicationRecord
  belongs_to :survey

  has_many :questions, through: :survey

  has_many :answers
  accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

  serialize :answer_records

  before_save do
    self.answer_records = answers
  end

  def answers_to(question)
    answer_records.select { |a| a.question_id == question.id }
  end
end
