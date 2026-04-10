class SurveyEditor::QuestionsController < SurveyEditorController
  def index
    render partial: 'questions', locals: { editor: }
  end

  def create
    Dragnet::SurveyEdit.new_question(survey)

    render partial: 'questions', locals: { editor: }
  end

  def update
    Dragnet::SurveyEdit.update_question(survey, question, question_params.to_h.symbolize_keys)

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
    hash       = params.require(:survey).require(:question).permit(:type, :text, :required).to_h
    type       = hash.delete(:type).presence.to_sym
    type_class = Dragnet::Type.find(type)

    hash.merge!(type_class: type_class)
  end
end
