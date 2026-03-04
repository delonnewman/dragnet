class Dragnet::SurveyEditorPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  delegate :edited?, to: :survey

  def last_updated_at
    return survey.updated_at unless edited?

    latest_edit.updated_at
  end

  def latest_edit
    Dragnet::SurveyEdit.latest(survey)
  end

  def new_edit(data)
    Dragnet::SurveyEdit.create_with!(survey, data:)
  end
end
