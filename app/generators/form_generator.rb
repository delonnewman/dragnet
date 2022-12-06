# frozen_string_literal: true

# Generate random forms
class FormGenerator < Dragnet::ActiveRecordGenerator
  DEFAULT_SETTINGS = { fields: { min: 4, max: 20 }.freeze }.freeze

  def call(other_attributes = DEFAULT_SETTINGS)
    Form.new(name: Faker::Lorem.sentence, author: attributes.fetch(:author, User.generate)) do |f|
      min, max = other_attributes.fetch(:fields).values_at(:min, :max)
      (min..max).to_a.sample.times do
        f.fields << Field[form: f].generate
      end
    end
  end
end
