# Generate random survey edits
class SurveyEditGenerator < Dragnet::ActiveRecordGenerator
  def call(survey_attributes = EMPTY_HASH)
    survey      = attributes.fetch(:survey) { Survey.generate!(survey_attributes) }
    survey_data = attributes.fetch(:survey_data) { survey.projection }

    SurveyEdit.new(survey: survey, survey_data: survey_data)
  end
end
