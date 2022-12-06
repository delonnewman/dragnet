class ResponseGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    form = attributes.fetch(:form) { raise 'A form attribute is required' }

    Response.new(form: form) do |r|
      r.created_at   = Faker::Date.between(from: 2.years.ago, to: Date.today)
      r.updated_at   = r.created_at
      r.submitted    = Faker::Boolean.boolean(true_ratio: 0.8)
      r.submitted_at = r.created_at if r.submitted?

      form.fields.each do |f|
        next unless f.required? || Faker::Boolean.boolean(true_ratio: 0.6)

        r.items << ResponseItem[form: form, response: r, field: f, field_type_id: f.field_type_id].generate
      end
    end
  end
end
