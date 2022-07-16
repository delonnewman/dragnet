# frozen_string_literal: true

# Logic for survey edit application
class SurveyEdit::Application
  attr_reader :edit

  delegate :valid?, :validate!, :errors, to: :validating_survey

  def initialize(edit)
    @edit = edit
  end

  def validating_survey
    Survey.new(survey_attributes)
  end

  def applied!(timestamp = Time.now)
    edit.applied = true
    edit.applied_at = timestamp
    edit
  end

  def apply!(timestamp = Time.now)
    SurveyEdit.transaction do
      # Commit changes to survey
      edit.survey.update(edit.survey_attributes)

      # Mark this draft as published
      applied!(timestamp).save!

      # Clean up old drafts
      edit.survey.edits.where.not(id: edit.id).delete_all

      edit
    end
  end
end
