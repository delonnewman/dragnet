class QuestionTypeGenerator < Dragnet::ActiveRecordGenerator
  TYPES = QuestionType.all.to_a

  def call(*)
    TYPES.sample
  end
end
