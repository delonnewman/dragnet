class SurveyEditor::QuestionsController < SurveyEditorController
  # NOTE: we may not need this
  def index
    render partial: 'questions', locals: { editor: }
  end

  def create
    # FIXME: should create new edit with question data
    question = survey.questions.create!

    render partial: 'question', locals: { editor:, question: }
  end

  def edit
  end

  def update
  end

  def delete
  end
end
