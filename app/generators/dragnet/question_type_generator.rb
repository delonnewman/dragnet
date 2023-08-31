# frozen_string_literal: true

class Dragnet::QuestionTypeGenerator < Dragnet::ActiveRecordGenerator
  TYPES = QuestionType.all.to_a

  def call(*)
    type = TYPES.sample
    return type if type

    QuestionType.new(name: 'text')
  end
end
