# An individual edit to a survey
class SurveyEdit < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  with SurveyEdit::Application, delegating: %i[apply! applied!]
  with SurveyEdit::SurveyAttributeProjection, as: :survey_attributes, calling: :attributes
end
