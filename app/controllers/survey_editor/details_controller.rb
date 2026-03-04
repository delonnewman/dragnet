class SurveyEditor::DetailsController < SurveyEditorController
  def index
    render :index, locals: { survey: }
  end

  def create
  end
end
