class FieldOptionGenerator < Dragnet::ActiveRecordGenerator
  def call(other_attributes = EMPTY_HASH)
    f      = attributes.fetch(:field) { raise 'A field attribute is required' }
    text   = Faker::Lorem.sentence
    weight = attributes.fetch(:weight, other_attributes.fetch(:weight, 1))
    order  = attributes.fetch(:display_order, other_attributes.fetch(:display_order, 0))

    FieldOption.new(field: f, text: text, weight: weight, display_order: order)
  end
end
