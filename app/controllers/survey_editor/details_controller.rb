class SurveyEditor::DetailsController < SurveyEditorController
  def show
    render partial: 'details', locals: { survey: editor.survey }
  end

  def update
    # TODO: just save the diff
    data = survey.projection.merge(details_params.to_h.symbolize_keys)
    edit = Dragnet::SurveyEdit.create_with!(survey, data:)

    render partial: 'details', locals: { survey: edit.edited_survey }
  end

  private

  def details_params
    params.require(:survey).permit(:name, :description)
  end
end
