# An individual edit to a survey
class SurveyEdit < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  with Application, delegating: %i[apply! applied!]
  with SurveyAttributeProjection, as: :survey_attributes, calling: :attributes

  after_save do
    if application.valid?
      survey.update(edits_status: :unsaved)
    else
      survey.update(edits_status: :cannot_save)
    end
  end
end
