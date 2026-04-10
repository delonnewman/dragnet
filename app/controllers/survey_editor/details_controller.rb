class SurveyEditor::DetailsController < SurveyEditorController
  def show
    render partial: 'details', locals: { survey: editor.survey.edited }
  end

  def update
    edit = Dragnet::SurveyEdit.update_attributes(survey, details_params.to_h.symbolize_keys)

    render partial: 'details', locals: { survey: edit.survey.edited }
  end

  private

  def details_params
    params.require(:survey).permit(:name, :description)
  end
end
