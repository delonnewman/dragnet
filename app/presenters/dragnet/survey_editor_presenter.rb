class Dragnet::SurveyEditorPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  delegate :edited?, to: :survey, prefix: :survey

  def last_updated_at
    return survey.updated_at unless survey_edited?

    latest_edit.created_at
  end

  def current_edit
    Dragnet::SurveyEdit.current(survey)
  end

  def latest_edit
    Dragnet::SurveyEdit.latest(survey)
  end

  def new_edit
    Dragnet::SurveyEdit.create_with!(survey)
  end

  def types
    TypeRegistration.where(abstract: false)
  end
end
