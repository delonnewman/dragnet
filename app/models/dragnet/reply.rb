# frozen_string_literal: true

module Dragnet
  class Reply < ApplicationRecord
    include Retractable

    CSRF_TOKEN_PRECISION = 256
    EXPIRATION_DURATION = 30.minutes # TODO: move this to configration

    retract_associated :answers

    belongs_to :survey, class_name: 'Dragnet::Survey'
    has_many :questions, class_name: 'Dragnet::Question', through: :survey

    has_many :answers, class_name: 'Dragnet::Answer', dependent: :delete_all, inverse_of: :reply
    accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

    # Analytics
    belongs_to :ahoy_visit, class_name: 'Ahoy::Visit', optional: true
    has_many :events, through: :ahoy_visit

    def ensure_visit(visit)
      update(ahoy_visit: visit) if visit && ahoy_visit_id != visit.id
    end

    # Answer caching (used for better performance in the data grid)
    with AnswersCache

    before_save do
      answers_cache.reset! if new_record? || cached_answers_data.blank?
    end

    after_save unless: :new_record? do
      # reload.answers_cache.reset!
    end

    def cached_answers
      answers_cache.answers
    end

    def answers_to(question)
      cached_answers.select { |a| a.question_id == question.id }
    end

    # Submission
    with ReplySubmissionPolicy, delegating: %i[can_edit_reply? can_update_reply? can_complete_reply?]
    delegate :submission_parameters, to: :survey
    scope :complete, -> { where(submitted: true) }
    scope :incomplete, -> { where(submitted: false) }
    validates :csrf_token, presence: true
    before_validation if: :new_record? do
      self.csrf_token = SecureRandom.urlsafe_base64(CSRF_TOKEN_PRECISION)
      self.expires_at = EXPIRATION_DURATION.from_now
    end

    # Cache submission date in survey to improve query performance for workspaces
    after_save if: :submitted? do
      survey.update(latest_submission_at: submitted_at)
    end

    def expired?(now = Time.zone.now)
      expires_at <= now
    end

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
    def submit(attributes, timestamp: Time.zone.now)
      assign_attributes(attributes)
      validate(:submission)
      submitted!(timestamp)
      save
    end
  end
end
