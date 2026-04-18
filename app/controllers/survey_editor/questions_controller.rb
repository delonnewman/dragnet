class SurveyEditor::QuestionsController < SurveyEditorController
  def index
    render partial: 'questions', locals: { editor: }
  end

  def create
    Dragnet::SurveyEdit.new_question(survey)

    render partial: 'editor', locals: { editor: }
  end

  def update
    Dragnet::SurveyEdit.update_question(survey, question.id, question_params)

    render partial: 'editor', locals: { editor: }
  end

  def destroy
    if question.new_question?
      id = question.id.to_s
      survey.edits.where("details->>'id' = ? or details->>'question_id' = ?", id, id).delete_all
    else
      Dragnet::SurveyEdit.remove_question(survey, question.id)
    end

    render partial: 'editor', locals: { editor: }
  end

  private

  def question
    @question ||= survey.edited.questions.find { |q| q.id == params[:id] }
  end
  
  def question_params
    params.require(:survey).require(:question).permit(:type, :text, :required).to_h.symbolize_keys
  end
end
