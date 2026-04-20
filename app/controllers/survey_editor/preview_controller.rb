class SurveyEditor::PreviewController < SurveyEditorController
  def show
    render :preview, locals: { survey: Dragnet::SurveyPresenter.new(survey.edited, params) }
  end

  def edit
    render 'replies/edit', locals: { reply: }, layout: 'external'
  end

  def update
    render 'replies/success', locals: { reply: }, layout: 'external'
  end

  private

  def reply
    Dragnet::PreviewPresenter.new(survey.replies.build)
  end
end
