# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :survey

  has_many :questions, through: :survey

  has_many :answers, dependent: :delete_all, inverse_of: :reply
  accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

  with Submission, delegating: %i[submit! submitted submitted!]
  scope :incomplete, -> { where(submitted: false) }

  # Analytics
  visitable :ahoy_visit

  # @!attribute answer_records
  #   @return [Array<Answer>]
  serialize :answer_records

  before_save do
    self.answer_records = answers
  end

  def answers_to(question)
    answer_records.select { |a| a.question_id == question.id }
  end
end
