# frozen_string_literal: true

# An individual edit to a survey
class SurveyEdit < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  with SurveyAttributeProjection, as: :survey_attributes, calling: :attributes
  with Application, delegating: %i[apply apply! applied! set_survey_edits_status]
  after_save :set_survey_edits_status
end
