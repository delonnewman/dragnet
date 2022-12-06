# frozen_string_literal: true

# Data projection for the survey editor API
class FormEditingPresenter < Dragnet::View::Presenter
  presents Form, as: :form

  def editing_data
    { form:        form.projection,
      updated_at:  form.updated_at.to_time,
      edits:       form_edits,
      field_types: field_types }
  end

  def form_edits
    edits = form.edits.pull(:id, :created_at)

    edits.map do |edit|
      { edit_id: edit[:id], created_at: edit[:created_at].to_time }
    end
  end

  def field_types
    types = FieldType.all.pull(:id, :name, :slug, :icon, settings: [:*])

    types.reduce({}) do |qt, type|
      qt.merge!(type[:id] => type)
    end
  end
end
