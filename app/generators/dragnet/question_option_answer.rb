class Dragnet::QuestionOptionAnswer < Dragnet::ParameterizedGenerator
  attr_reader :question

  delegate :type, to: :question

  def initialize(question)
    super()

    @question = question
  end

  def question_options
    @question_options ||= question.question_options.to_a
  end

  def call(*)
    case type.class.symbol
    when :choice
      question_options.sample
    end
  end
end
