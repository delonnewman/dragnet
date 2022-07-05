class SurveyEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    render json: transit(editing_data), content_type: 'application/transit+json'
  end

  # POST / PATCH - /api/v1/editing/surveys/:id
  def update
    draft.update(survey_data: read_transit(request.body))
  end

  private

  def transit(data)
    io = StringIO.new
    Transit::Writer.new(:json, io).write(data)
    io.string
  end

  def read_transit(io)
    Transit::Reader.new(:json, io).read
  end

  def draft
    Survey.find(params[:id]).draft
  end

  def editing_data
    { survey: draft.survey_data, question_types: question_types }
  end

  def question_types
    QuestionType
      .all
      .pull(:id, :name, :slug, :icon, settings: %i[*])
      .reduce({}) { |types, type| types.merge!(type[:id] => type) }
  end
end
