class SurveyEditor::PreviewController < SurveyEditorController
  def show
    render :preview, locals: { survey: Dragnet::SurveyPresenter.new(survey.edited, params) }
  end

  def edit
    render 'replies/edit', locals: { reply: survey.replies.build, survey: survey.edited }, layout: 'external'
  end

  def update
  end
end
