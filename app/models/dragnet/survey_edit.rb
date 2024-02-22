# frozen_string_literal: true

module Dragnet
  # An individual edit to a survey
  class SurveyEdit < ApplicationRecord
    belongs_to :survey, class_name: 'Dragnet::Survey'

    serialize :survey_data

    with SurveyAttributeProjection, as: :survey_attributes, calling: :attributes
    with Application, delegating: %i[apply apply! applied! set_survey_edits_status]
    after_save :set_survey_edits_status
  end
end
