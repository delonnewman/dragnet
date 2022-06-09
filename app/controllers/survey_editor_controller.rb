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

    render json: transit(data), content_type: 'application/transit+json'
  end

  # POST / PATCH - /api/v1/editing/surveys/:id
  def update
    survey.update(read_transit(request.body))
  end

  private

  def survey
    Survey.find(params[:id])
  end

  def transit(data)
    io = StringIO.new
    Transit::Writer.new(:json, io).write(data)
    io.string
  end

  def read_transit(string)
    Transit::Reader.new(:json, StringIO.new(string)).read
  end
end
