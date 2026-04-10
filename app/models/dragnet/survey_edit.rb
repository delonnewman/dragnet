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

    def self.update_attributes(survey, updates)
      create!(survey:, op: Op.update, details: { updates: })
    end

    def self.new_question(survey)
      create!(survey:, op: Op.new_question)
    end

    def self.update_question(survey, question_id, updates)
      create!(survey:, op: Op.update_question, details: { question_id:, updates: })
    end

    def self.remove_question(survey, question)
      question_id = question.is_a?(Question) ? question.id : question
      create!(survey:, op: Op.remove_question, details: { question_id: })
    end

    def self.merge(survey, edits:)
      projection = edits.reduce(survey.projection) do |projection, edit| 
        edit.op.merge(edit, projection)
      end
      EditedSurvey.new(Survey::AttributeProjection.new(projection).to_h)
    end

    def self.current(survey)
      latest(survey) || build_with(survey)
    end

    def self.create_with!(survey, data: survey.projection)
      build_with(survey, data:).tap(&:save!)
    end

    def self.build_with(survey, data: survey.projection)
      new(survey:, details: data)
    end

    def self.present?(survey)
      latest(survey).present?
    end

    def self.latest(survey)
      survey.edits.not_applied.order(created_at: :desc).first
    end

    def applied?
      !applied_at.nil?
    end

    # @param [Time] timestamp
    # @return [SurveyEdit]
    def applied!(timestamp = Time.zone.now)
      edited_survey.validate!(:application)
      self.applied_at = timestamp
      self
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
      return unless applied!(timestamp)

      errors.merge!(edited_survey.errors)
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
  end
end
