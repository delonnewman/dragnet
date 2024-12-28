# frozen_string_literal: true

module Dragnet
  # An individual edit to a survey
  class SurveyEdit < ApplicationRecord
    belongs_to :survey, class_name: 'Dragnet::Survey'

    serialize :survey_data
    after_save { Survey::EditingStatus.update!(self) }

    def self.current(survey)
      latest(survey) || build_with(survey)
    end

    def self.create_with!(survey, data: survey.projection)
      build_with(survey, data:).tap(&:save!)
    end

    def self.build_with(survey, data: survey.projection)
      new(survey:, survey_data: data)
    end

    def self.present?(survey)
      latest(survey).present?
    end

    def self.latest(survey)
      survey.edits.where(applied: false).order(created_at: :desc).first
    end

    # @param [Time] timestamp
    # @return [SurveyEdit]
    def applied(timestamp = Time.zone.now)
      return false unless valid?(:application)

      self.applied    = true
      self.applied_at = timestamp
      self
    end

    # @param [Time] timestamp
    # @return [SurveyEdit]
    def applied!(timestamp = Time.zone.now)
      validating_survey.validate!(:application)
      applied(timestamp)
    end

    # @param [Time] timestamp
    #
    # @raise [ActiveRecord::RecordInvalid]
    #
    # @return [Survey, Class<ActiveRecord::Rollback>, false]
    def apply(timestamp = Time.zone.now)
      apply!(timestamp)
    rescue ActiveRecord::RecordInvalid
      false
    end

    # @param [Time] timestamp
    #
    # @raise [ActiveRecord::RecordInvalid]
    #
    # @return [Survey, Class<ActiveRecord::Rollback>]
    def apply!(timestamp = Time.zone.now)
      SurveyEdit.transaction do
        mark_as_published(timestamp)
        commit_changes(timestamp)
        save!
        clean_up_old_drafts
        survey
      end
    end

    private

    # Mark as published and validate without saving
    def mark_as_published(timestamp)
      return unless applied(timestamp)

      errors.merge!(validating_survey.errors)
      raise ActiveRecord::RecordInvalid, self
    end

    # Commit changes to survey
    def commit_changes(timestamp)
      survey.attributes = survey_attributes.merge(updated_at: timestamp)
      Survey::EditingStatus.saved!(survey)
      survey.save!
    end

    def clean_up_old_drafts
      survey.edits.where.not(id:).delete_all
    end

    def survey_attributes
      Survey::AttributeProjection.new(survey_data).to_h
    end

    # @return [Survey]
    def validating_survey
      Survey.new(survey_attributes)
    end
  end
end
