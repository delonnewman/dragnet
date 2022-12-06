class FormEditorController < ActionController::API
  # GET - /api/v1/editing/surveys/:id
  def show
    render json: transit(form_editing.editing_data), content_type: 'application/transit+json'
  end

  # PUT / PATCH - /api/v1/editing/surveys/:id
  def update
    edit = form.edits.create!(survey_data: read_transit(request.body))

    render json: transit(edit_id: edit.id, created_at: edit.created_at.to_time), content_type: 'application/transit+json'
  end

  # POST - /api/v1/editing/surveys/:id/apply
  def apply
    updated =
      form
        .latest_edit
        .if_nil { raise "Couldn't find draft to apply" }
        .apply!

    render json: transit(form_editing(updated).editing_data), content_type: 'application/transit+json'
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

  def form_editing(form = self.form)
    FormEditingPresenter.new(form)
  end

  def form
    Form.find(params[:id])
  end
end
