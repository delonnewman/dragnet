class Reply < ApplicationRecord
  belongs_to :survey

  has_many :questions, through: :survey

  has_many :answers
  accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

  with Reply::Submission, delegating: %i[submit! submitted submitted!]

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
