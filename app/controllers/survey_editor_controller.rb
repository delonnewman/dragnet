class SurveyEditorController < EndpointsController
  # GET - /api/v1/editing/surveys/:id
  def show
    respond_to do |format|
      format.transit { render body: transit(survey_editing.editing_data) }
    end
  end

  # PUT / PATCH - /api/v1/editing/surveys/:id
  def update
    edit = survey.edits.create!(survey_data: read_transit(request.body))

    respond_to do |format|
      format.transit { render body: transit(edit_id: edit.id, created_at: edit.created_at.to_time) }
    end
  end

  # POST - /api/v1/editing/surveys/:id/apply
  def apply
    updated =
      survey
        .latest_edit
        .if_nil { raise "Couldn't find draft to apply" }
        .apply!

    respond_to do |format|
      format.transit { render body: transit(survey_editing(updated).editing_data) }
    end
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
