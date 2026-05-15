# frozen_string_literal: true

module Dragnet
  # An individual edit to a survey
  class SurveyEdit < ApplicationRecord
    attribute :op, Op, default: Op.update
    attribute :applied_at, :datetime
    attribute :created_at, :datetime

    belongs_to :survey, class_name: 'Dragnet::Survey'

    attribute :details, :json_with_symbolized_keys
    after_save { Survey::EditingStatus.update!(self) }

    scope :applied, -> { where.not(applied_at: nil) }
    scope :not_applied, -> { where(applied_at: nil) }

    def applied?
      !applied_at.nil?
    end

    def applied!(timestamp = Time.zone.now)
      self.applied_at = timestamp
      self
    end

    def apply(timestamp = Time.zone.now)
      apply!(timestamp)
    rescue ActiveRecord::RecordInvalid
      false
    end

    def apply!(timestamp = Time.zone.now)
      applied!(timestamp).save!
    end
  end
end
