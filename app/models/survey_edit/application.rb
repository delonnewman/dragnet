# frozen_string_literal: true

# Logic for applying survey edits to a survey to preserve the changes
class SurveyEdit::Application < Dragnet::Advice
  advises SurveyEdit, as: :edit

  attr_reader :validating_survey

  delegate :valid?, :validate!, :errors, to: :validating_survey
  delegate :survey, to: :edit

  def initialize(edit)
    super(edit)
    @validating_survey = Survey.new(edit.survey_attributes)
  end

  def applied(timestamp = Time.now)
    return false unless valid?(:application)

    edit.applied = true
    edit.applied_at = timestamp
    edit
  end

  def applied!(timestamp = Time.now)
    validate!(:application)
    applied(timestamp)
  end

  def set_survey_edits_status
    return if edit.applied?

    if valid?
      survey.update(edits_status: :unsaved)
    else
      survey.update(edits_status: :cannot_save)
    end
  end

  def apply!(timestamp = Time.now)
    SurveyEdit.transaction do
      # Mark as published and validate without saving
      unless applied(timestamp)
        edit.errors.merge!(errors)
        raise ActiveRecord::RecordInvalid.new(edit)
      end

      # Commit changes to survey
      survey.update!(edit.survey_attributes.merge(updated_at: timestamp, edits_status: :saved))

      # Save changes to edit
      edit.save!

      # Clean up old drafts
      survey.edits.where.not(id: edit.id).delete_all

      survey
    end
  end

  def apply(timestamp = Time.now)
    apply!(timestamp)
  rescue ActiveRecord::RecordInvalid
    false
  end
end
