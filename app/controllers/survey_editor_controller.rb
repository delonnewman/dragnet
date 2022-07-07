class SurveyEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    render json: transit(editing_data), content_type: 'application/transit+json'
  end

  # PUT / PATCH - /api/v1/editing/surveys/:id
  def update
    draft = survey.drafts.create(survey_data: read_transit(request.body))

    render json: transit(draft_id: draft.id, created_at: draft.created_at.to_time),
           content_type: 'application/transit+json'
  end

  # POST - /api/v1/editing/surveys/:id/apply
  def apply
    survey
      .latest_draft
      .nil { raise "Couldn't find draft to apply" }
      .apply!

    render json: transit(editing_data), content_type: 'application/transit+json'
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

  def editing_data
    { survey: survey.current_draft.survey_data,
      question_types: question_types,
      drafts: survey_drafts }
  end

  def survey_drafts
    survey
      .drafts
      .pull(:id, :created_at)
      .map { |draft| { draft_id: draft[:id], created_at: draft[:created_at].to_time } }
  end

  def question_types
    QuestionType
      .all
      .pull(:id, :name, :slug, :icon, settings: %i[*])
      .reduce({}) { |types, type| types.merge!(type[:id] => type) }
  end
end
