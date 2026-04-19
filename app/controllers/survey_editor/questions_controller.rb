class SurveyEditor::QuestionsController < SurveyEditorController
  def create
    Dragnet::SurveyEdit.new_question(survey)

    render :questions, locals: { editor: }
  end

  def update
    Dragnet::SurveyEdit.update_question(survey, question.id, question_params)

    render :question, locals: { editor:, question: }
  end

  def destroy
    question = self.question
    if question.new_question?
      id = question.id.to_s
      survey.edits.where("details->>'id' = ? or details->>'question_id' = ?", id, id).delete_all
    else
      Dragnet::SurveyEdit.remove_question(survey, question.id)
    end

    render :questions, locals: { editor: }
  end

  private

  def question
    survey.edited.questions.find { |q| q.id == params[:id] }
  end
  
  def question_params
    params.require(:survey).require(:question).permit(:type, :text, :required).to_h.symbolize_keys
  end
end
