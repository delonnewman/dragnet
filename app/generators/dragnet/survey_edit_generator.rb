# Generate random survey edits
class Dragnet::SurveyEditGenerator < Dragnet::ActiveRecordGenerator
  def call(survey_attributes = EMPTY_HASH)
    survey  = attributes.fetch(:survey) { Survey.generate!(survey_attributes) }
    details = attributes.fetch(:details) { survey.projection }

    SurveyEdit.new(survey: survey, details:)
  end
end
