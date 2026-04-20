class Dragnet::PreviewPresenter < Dragnet::ReplyFormPresenter
  def survey
    reply.survey.edited
  end

  def submission_action
    survey_editor_preview_path(survey)
  end
  
  def submission_method
    :put
  end
end
