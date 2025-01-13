# frozen_string_literal: true

# Data projection for the survey editor API
class Dragnet::SurveyEditingPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  def editing_data
    {
      survey:         survey_data,
      updated_at:     survey.updated_at.to_time,
      edits:          survey_edits,
      type_hierarchy: Dragnet::Type.hierarchy(reference: :symbol),
      type_registry:  types,
    }
  end

  def types
    QuestionTypesPresenter.new(TypeRegistration.where(abstract: false)).question_types_mapping
  end

  def survey_data
    return survey.projection unless survey.edited?

    SurveyEdit.latest(survey).survey_data
  end

  def survey_edits
    edits = survey.edits.pull(:id, :created_at)

    edits.map do |edit|
      { edit_id: edit[:id], created_at: edit[:created_at].to_time }
    end
  end
end
