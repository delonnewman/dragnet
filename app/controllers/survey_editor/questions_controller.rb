class SurveyEditor::QuestionsController < SurveyEditorController
  def index
    render partial: 'questions', locals: { editor: }
  end

  def create
    # TODO: should create new edit with question data
    question = survey.questions.create!

    render partial: 'question', locals: { editor:, question: }
  end

  def update
    # TODO: should create new edit with updated question data
    if question.update(question_params)
      render partial: 'question', locals: { editor:, question: }
    else
      # TODO: handle errors
    end
  end

  def destroy
    # TODO: should create new edit with question data removed
    question.destroy

    render partial: 'questions', locals: { editor: }
  end

  private

  def question
    @question ||= survey.questions.find(params[:id])
  end
  
  def question_params
    hash = params.require(:survey).require(:question).permit(:type, :text, :required).to_h
    type = hash.delete(:type).presence.to_sym
    type_class = Dragnet::Type.find(type)
    hash.merge!(type_class: type_class)
  end
end
