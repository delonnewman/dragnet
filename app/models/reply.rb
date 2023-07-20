# frozen_string_literal: true

class Reply < ApplicationRecord
  belongs_to :survey

  has_many :questions, through: :survey

  has_many :answers, dependent: :delete_all, inverse_of: :reply
  accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

  with Submission, delegating: %i[submit! submitted!]
  scope :incomplete, -> { where(submitted: false) }

  # Analytics
  belongs_to :ahoy_visit, class_name: 'Ahoy::Visit', optional: true
  has_many :events, through: :ahoy_visit
  before_create do
    self.ahoy_visit_id = Ahoy.instance.try(:visit_or_create)&.id unless ahoy_visit_id?
  end

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
