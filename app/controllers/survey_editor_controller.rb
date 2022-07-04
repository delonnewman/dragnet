class SurveyEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    render json: transit(editing_data), content_type: 'application/transit+json'
  end

  # POST / PATCH - /api/v1/editing/surveys/:id
  def update
    draft.update(read_transit(request.body))
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

  # TODO: use actual SurveyDraft instance
  def draft
    Survey.find(params[:id])
  end

  def editing_data
    { survey: survey, question_types: question_types }
  end

  def survey
    data = draft.pull(
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

    questions = data[:questions].inject({}) do |qs, q|
      q[:question_options] = q[:question_options].inject({}) { |opts, opt| opts.merge!(opt[:id] => opt) }
      qs.merge!(q[:id] => q)
    end

    data.merge(questions: questions)
  end

  def question_types
    QuestionType
      .all
      .pull(:id, :name, :slug, :icon, settings: %i[*])
      .reduce({}) { |types, type| types.merge!(type[:id] => type) }
  end
end
