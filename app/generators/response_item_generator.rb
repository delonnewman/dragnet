class ResponseItemGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    form  = attributes.fetch(:form)     { raise 'A form attribute is required' }
    res   = attributes.fetch(:response) { raise 'A response attribute is required' }
    field = attributes.fetch(:field)    { raise 'A field attribute is required' }

    # TODO: Add support for multiple choice
    v = case field.field_type.ident
        when :text
          ShortAnswer.generate
        when :choice
          FieldOptionAnswer[field].generate
        when :number
          Random.rand(100)
        when :time
          Faker::Time.between(from: 3.months.ago, to: Time.now)
        else
          raise "Don't know how to generate an answer for #{field.field_type.ident.inspect}"
        end

    ResponseItem.new(form: form, response: res, field: field) do |item|
      item.field_type = field.field_type
      item.value = v
    end
  end
end
