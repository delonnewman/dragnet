class SurveyEdit < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  composes SurveyEdit::Application, delegating: %i[apply! applied!]
  composes SurveyEdit::SurveyAttributeProjector, as: :survey_attributes, calling: :call
end
