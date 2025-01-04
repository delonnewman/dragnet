# frozen_string_literal: true

module Dragnet
  class Reply < ApplicationRecord
    include Retractable

    belongs_to :survey, class_name: 'Dragnet::Survey'
    has_many :questions, class_name: 'Dragnet::Question', through: :survey

    # Answers
    has_many :answers, class_name: 'Dragnet::Answer', dependent: :delete_all, inverse_of: :reply
    accepts_nested_attributes_for :answers, reject_if: ->(attrs) { Answer.new(attrs).blank? }

    retract_associated :answers

    with AnswersCache
    attribute :cached_answers_data, default: []
    after_save { answers_cache.set! if submitted? && answers_cache.not_set? }

    def cached_answers
      answers_cache.answers
    end

    def answers_to(question)
      cached_answers.select { |a| a.question_id == question.id }
    end

    # Analytics
    belongs_to :ahoy_visit, class_name: 'Ahoy::Visit', optional: true
    has_many :events, through: :ahoy_visit

    def ensure_visit(visit)
      update(ahoy_visit: visit) if visit && ahoy_visit_id != visit.id
    end

    # Submission
    with ReplySubmissionPolicy, delegating: %i[can_edit_reply? can_update_reply? can_complete_reply?]

    CSRF_TOKEN_PRECISION = 256
    EXPIRATION_DURATION = 30.minutes # TODO: move this to configration

    delegate :submission_parameters, to: :survey

    scope :incomplete, -> { where(submitted: false) }

    validates :csrf_token, presence: true

    before_validation if: :new_record? do
      self.csrf_token = SecureRandom.urlsafe_base64(CSRF_TOKEN_PRECISION)
      self.expires_at = EXPIRATION_DURATION.from_now
    end

    # Cache submission date in survey to improve query performance for workspaces
    after_save do
      survey.update(latest_submission_at: submitted_at) if submitted?
    end

    def expired?(now = Time.zone.now)
      expires_at <= now
    end

    def submitted!(timestamp)
      self.submitted    = true
      self.submitted_at = timestamp
      self
    end

    def submit(attributes, timestamp: Time.zone.now)
      assign_attributes(attributes)
      validate(:submission)
      submitted!(timestamp)
      save
    end
  end
end
