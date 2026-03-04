class SurveyEditor::DetailsController < SurveyEditorController
  def index
    render :index, locals: { editor: }
  end

  def create
  end
end
