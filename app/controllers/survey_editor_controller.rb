class SurveyEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    data = survey.pull(
      :name,
      :description,
      questions: %i[id
                    text
                    display_order
                    required
                    question_type_id
                    question_id
                    question_option_id]
    )

    render plain: data.to_edn, content_type: "text/edn"
  end

  # POST / PATCH - /api/v1/editing/surveys/:id
  def update
    survey.update(EDN.read(request.body))
  end

  private

  def survey
    Survey.find(params[:id])
  end
end
