# frozen_string_literal: true

# Logic for survey edits
class Form::Editing < Dragnet::Advice
  advises Form

  def latest_edit
    form.edits.where(applied: false).order(created_at: :desc).first
  end

  def edited?
    latest_edit.present?
  end

  def current_edit
    latest_edit || new_edit
  end

  def new_edit
    FormEdit.new(form: form, form_data: projection)
  end

  def projection
    data = form.pull(
      :id,
      :name,
      :description,
      :updated_at,
      :author_id,
      fields: [
        :id,
        :text,
        :display_order,
        :required,
        :field_type_id,
        {
          field_options: %i[id text weight]
        }
      ]
    )

    data[:updated_at] = data[:updated_at]&.to_time

    fields = data[:fields].inject({}) do |fs, f|
      f[:field_options] = f[:field_options].inject({}) do |opts, opt|
        opts.merge!(opt[:id] => opt)
      end

      fs.merge!(f[:id] => f)
    end

    data.merge(fields: fields)
  end
end
