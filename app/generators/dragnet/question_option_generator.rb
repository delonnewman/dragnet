class Dragnet::QuestionOptionGenerator < Dragnet::ActiveRecordGenerator
  def call(other_attributes = EMPTY_HASH)
    q      = attributes.fetch(:question) { raise 'A question attribute is required' }
    text   = Faker::Lorem.sentence
    weight = attributes.fetch(:weight, other_attributes.fetch(:weight, 1))
    order  = attributes.fetch(:display_order, other_attributes.fetch(:display_order, 0))

    QuestionOption.new(question: q, text: text, weight: weight, display_order: order)
  end
end
