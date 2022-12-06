# Generate a random field
class FieldGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    Field.new do |f|
      f.text       = Faker::Lorem.question
      f.form       = attributes.fetch(:form) { raise 'A form attribute is required' }
      f.field_type = attributes.fetch(:field_type, FieldType.generate)
      f.required   = Faker::Boolean.boolean(true_ratio: 0.3)

      case f.field_type.ident
      when :choice
        count = (2..5).to_a.sample
        count.times do |i|
          f.field_options << FieldOption[field: f, weight: i - (count / 2)].generate
        end
      end
    end
  end
end
