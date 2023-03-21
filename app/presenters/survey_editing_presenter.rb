# frozen_string_literal: true

# Data projection for the survey editor API
class SurveyEditingPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  def editing_data
    { survey:         survey_data,
      updated_at:     survey.updated_at.to_time,
      edits:          survey_edits,
      question_types: question_types }
  end

  def survey_data
    return survey.projection unless survey.edited?

    survey.latest_edit.survey_data
  end

  def survey_edits
    edits = survey.edits.pull(:id, :created_at)

    edits.map do |edit|
      { edit_id: edit[:id], created_at: edit[:created_at].to_time }
    end
  end

  def question_types
    QuestionTypesPresenter.new(QuestionType.all).question_types_mapping
  end
end
