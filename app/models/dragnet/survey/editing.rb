# frozen_string_literal: true

module Dragnet
  # Logic for survey edits
  class Survey::Editing < Advice
    advises Survey

    delegate :valid?, to: :latest_edit, prefix: :latest_edit

    def set_default_edits_status
      survey.edits_status = :saved unless survey.edits_status?
    end

    def edited?
      latest_edit.present?
    end

    def current_edit
      latest_edit || new_edit
    end

    def latest_edit
      survey.edits.where(applied: false).order(created_at: :desc).first
    end

    def new_edit
      SurveyEdit.new(survey:, survey_data: survey.projection)
    end
  end
end
