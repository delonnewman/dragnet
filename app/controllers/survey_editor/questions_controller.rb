class SurveyEditor::QuestionsController < SurveyEditorController
  def index
    render partial: 'questions', locals: { editor: }
  end

  def create
    Dragnet::SurveyEdit.new_question(survey)

    render partial: 'questions', locals: { editor: }
  end

  def update
    Dragnet::SurveyEdit.update_question(survey, question, question_params)
    # question = editor.survey.edited.find_question(self.question.id)

    # render partial: 'question', locals: { editor:, question: }
    render partial: 'questions', locals: { editor: }
  end

  def destroy
    Dragnet::SurveyEdit.remove_question(survey, question)

    render partial: 'questions', locals: { editor: }
  end

  private

  def question
    @question ||= survey.questions.find(params[:id])
  end
  
  def question_params
    params.require(:survey).require(:question).permit(:type, :text, :required).to_h.symbolize_keys
  end
end
