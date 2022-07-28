# frozen_string_literal: true

# Logic for survey edit application
class SurveyEdit::Application < Dragnet::Advice
  advises SurveyEdit, alias_as: :edit

  attr_reader :validating_survey

  delegate :valid?, :validate!, :errors, to: :validating_survey

  def initialize(edit)
    super(edit)
    @validating_survey = Survey.new(edit.survey_attributes)
  end

  def applied(timestamp = Time.now)
    edit.applied = true
    edit.applied_at = timestamp
    edit
  end

  def applied!(timestamp = Time.now)
    validate!(:application)
    applied(timestamp)
  end

  def apply!(timestamp = Time.now)
    SurveyEdit.transaction do
      # Commit changes to survey
      edit.survey.update(edit.survey_attributes.merge(updated_at: timestamp))

      # Mark this draft as published
      applied!(timestamp).save!

      # Clean up old drafts
      edit.survey.edits.where.not(id: edit.id).delete_all

      edit.survey
    end
  end
end
