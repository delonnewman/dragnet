class SurveyEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    survey_data = survey.pull(
      :name,
      :description,
      questions: [
        :id,
        :text,
        :display_order,
        :required,
        :question_type_id,
        {
          question_options: %i[id text weight]
        }
      ]
    )

    data = {
      survey: survey_data.merge(questions: survey_data[:questions].group_by { |q| q[:id] }.transform_values(&:first)),
      question_types: QuestionType.all.pull(:id, :name, :slug).group_by { |t| t[:id] }.transform_values(&:first)
    }

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

  def read_transit(io)
    Transit::Reader.new(:json, io).read
  end
end
