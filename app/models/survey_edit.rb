class SurveyEdit < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  advised_by SurveyEdit::Application, delegating: %i[apply! applied!]
  advised_by SurveyEdit::SurveyAttributeProjector, as: :survey_attributes, calling: :call
end
