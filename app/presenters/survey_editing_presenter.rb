# frozen_string_literal: true

# Data projection for the survey editor API
class SurveyEditingPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  def editing_data
    { survey: survey.current_edit.survey_data,
      question_types: question_types,
      edits: survey_edits }
  end
  alias to_h editing_data

  def survey_edits
    survey
      .edits
      .pull(:id, :created_at)
      .map { |draft| { draft_id: draft[:id], created_at: draft[:created_at].to_time } }
  end

  def question_types
    QuestionType
      .all
      .pull(:id, :name, :slug, :icon, settings: %i[*])
      .reduce({}) { |types, type| types.merge!(type[:id] => type) }
  end
end
