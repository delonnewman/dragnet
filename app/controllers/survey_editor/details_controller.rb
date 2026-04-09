class SurveyEditor::DetailsController < SurveyEditorController
  def show
    render partial: 'details', locals: { survey: editor.survey }
  end

  def update
  end
end
