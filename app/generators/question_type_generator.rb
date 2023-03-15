class QuestionTypeGenerator < Dragnet::ActiveRecordGenerator
  TYPES = QuestionType.all.to_a

  def call(*)
    type = TYPES.sample
    return type if type

    QuestionType.new(name: "text", answer_value_field: 'short_text_value')
  end
end
