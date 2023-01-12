# frozen_string_literal: true

# Logic for survey edits
class Survey::Editing < Dragnet::Advice
  advises Survey

  def latest_edit
    survey.edits.where(applied: false).order(created_at: :desc).first
  end

  def edited?
    latest_edit.present?
  end

  def current_edit
    latest_edit || new_edit
  end

  def new_edit
    SurveyEdit.new(survey: survey, survey_data: survey.projection)
  end
end
