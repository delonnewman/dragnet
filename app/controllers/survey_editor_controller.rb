class SurveyEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    render json: transit(editing_data), content_type: 'application/transit+json'
  end

  # POST / PATCH - /api/v1/editing/surveys/:id
  def update
    survey.draft.update(survey_data: read_transit(request.body))
  end

  def publish
    latest_draft
      .nil { raise "Couldn't find draft to publish" }
      .publish!

    redirect_to root_path
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

  def survey
    Survey.find(params[:id])
  end

  def latest_draft
    SurveyDraft.where(survey_id: params[:id], published: false).order(created_at: :desc).first
  end

  def draft
    latest_draft || survey.draft
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
