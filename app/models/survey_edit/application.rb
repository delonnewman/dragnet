# frozen_string_literal: true

# Logic for survey edit application
class SurveyEdit::Application
  attr_reader :edit, :validating_survey

  delegate :valid?, :validate!, :errors, to: :validating_survey

  def initialize(edit)
    @edit = edit
    @validating_survey = Survey.new(edit.survey_attributes)
  end

  def applied!(timestamp = Time.now)
    validate!(:application)

    edit.applied = true
    edit.applied_at = timestamp

    edit
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
