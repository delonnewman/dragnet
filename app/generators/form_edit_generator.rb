# Generate random form edits
class FormEditGenerator < Dragnet::ActiveRecordGenerator
  def call(form_attributes = EMPTY_HASH)
    form      = attributes.fetch(:form) { Form.generate!(form_attributes) }
    form_data = attributes.fetch(:form_data) { form.projection }

    FormEdit.new(form: form, form_data: form_data)
  end
end
