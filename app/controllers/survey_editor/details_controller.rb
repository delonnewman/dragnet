class SurveyEditor::DetailsController < SurveyEditorController
  def update
    Dragnet::SurveyEdit.update_attributes(survey, details_params)

    render :details, locals: { editor: }
  end

  private

  def details_params
    params.require(:survey).permit(:name, :description).to_h.symbolize_keys
  end
end
