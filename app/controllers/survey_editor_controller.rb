class SurveyEditorController < APIController
  # GET - /api/v1/editing/surveys/:id
  def show
    render json: transit(survey_editing.editing_data), content_type: 'application/transit+json'
  end

  # PUT / PATCH - /api/v1/editing/surveys/:id
  def update
    edit = survey.edits.create!(survey_data: read_transit(request.body))

    render json: transit(edit_id: edit.id, created_at: edit.created_at.to_time), content_type: 'application/transit+json'
  end

  # POST - /api/v1/editing/surveys/:id/apply
  def apply
    updated =
      survey
        .latest_edit
        .if_nil { raise "Couldn't find draft to apply" }
        .apply!

    render json: transit(survey_editing(updated).editing_data), content_type: 'application/transit+json'
  end

  private

  def survey
    Survey
      .includes(questions: %i[question_type question_options followup_questions])
      .find(params[:id])
  end

  def survey_editing(s = survey)
    SurveyEditingPresenter.new(s)
  end
end
