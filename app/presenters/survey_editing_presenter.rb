# frozen_string_literal: true

# Data projection for the survey editor API
class SurveyEditingPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  def editing_data
    { survey: survey.projection,
      question_types: question_types,
      edits: survey_edits }
  end
  alias to_h editing_data

  def survey_edits
    edits = survey.edits.pull(:id, :created_at)

    edits.map do |edit|
      { edit_id: edit[:id], created_at: edit[:created_at].to_time }
    end
  end

  def question_types
    types = QuestionType.all.pull(:id, :name, :slug, :icon, settings: %i[*])

    types.reduce({}) do |types, type|
      types.merge!(type[:id] => type)
    end
  end
end
