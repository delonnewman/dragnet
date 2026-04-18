class SurveyEditor::DetailsController < SurveyEditorController
  def show
    render partial: 'editor', locals: { editor: }
  end

  def update
    Dragnet::SurveyEdit.update_attributes(survey, details_params)

    render partial: 'editor', locals: { editor: }
  end

  private

  def details_params
    params.require(:survey).permit(:name, :description).to_h.symbolize_keys
  end
end
