# frozen_string_literal: true

module Dragnet
  class Reply < ApplicationRecord
    include Retractable

    retract_associated :answers

    belongs_to :survey, class_name: 'Dragnet::Survey'
    has_many :questions, class_name: 'Dragnet::Question', through: :survey

    has_many :answers, class_name: 'Dragnet::Answer', dependent: :delete_all, inverse_of: :reply
    accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

    # Submission
    delegate :submission_parameters, to: :survey
    scope :incomplete, -> { where(submitted: false) }

    # Analytics
    belongs_to :ahoy_visit, class_name: 'Ahoy::Visit', optional: true
    has_many :events, through: :ahoy_visit
    before_create do
      self.ahoy_visit = Ahoy.instance.try(:visit_or_create) unless ahoy_visit_id?
    end

    # Cache submission date in survey to improve query performance for workspaces
    after_save do
      survey.update(latest_submission_at: submitted_at) if submitted?
    end

    before_save :reset_answers_data!

    def reset_answers_data!
      self.answers_data = AnswerRecords.new(self).data
    end

    def answers_to(question)
      answer_records.select { |a| a.question_id == question.id }
    end

    def answer_records
      AnswerRecords.build(answers_data)
    end
    memoize :answer_records

    # Mark the reply as submitted
    #
    # @param [Time] timestamp
    #
    # @return [Reply]
    def submitted!(timestamp)
      self.submitted    = true
      self.submitted_at = timestamp
      self
    end

    # Apply changes to attributes, validate, mark as submitted and save the reply
    #
    # @param [Hash{Symbol, String => Object}, ActionController::Parameters] attributes
    # @param [Time] timestamp
    #
    # @return [Boolean]
    def submit!(attributes, timestamp: Time.zone.now)
      self.attributes = attributes
      validate!(:submission)
      submitted!(timestamp)
      save!
    end
  end
end
