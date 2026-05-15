class SurveyEditor::DisplayOrderController < SurveyEditorController
  def update
    updates = question_ids.each_with_index.map { |id, order| [id, order] }
    Dragnet::SurveyEdit.transaction do
      updates.each do |(id, order)| 
        survey.edits.update_question(id, display_order: order)
      end
    end

    render :questions, locals: { editor: }
  end

  private

  def question_ids
    params.require(:survey).require(:question).permit(id: []).fetch(:id)
  end
end
