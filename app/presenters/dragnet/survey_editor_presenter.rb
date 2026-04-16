class Dragnet::SurveyEditorPresenter < Dragnet::View::Presenter
  presents Survey, as: :survey

  delegate :edited?, to: :survey, prefix: :survey

  def last_updated_at
    return survey.updated_at unless survey_edited?

    latest_edit.created_at
  end

  def latest_edit
    survey.edits.latest
  end

  def types
    TypeRegistration.where(abstract: false)
  end
end
