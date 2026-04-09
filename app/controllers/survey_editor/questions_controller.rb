class SurveyEditor::QuestionsController < SurveyEditorController
  def index
    render partial: 'questions', locals: { editor: }
  end

  def new
    # FIXME: should create new edit with question data
    question = survey.questions.create!

    render partial: 'question', locals: { editor:, question: }
  end

  def create
  end

  def edit
  end

  def update
  end

  def delete
  end
end
