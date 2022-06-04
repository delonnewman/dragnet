class QuestionOptionAnswer < Dragnet::ParameterizedGenerator
  attr_reader :question

  delegate :question_type, to: :question

  def initialize(question)
    super()

    @question = question
  end

  def question_options
    @question_options ||= question.question_options.to_a
  end

  def call(*)
    case question_type.ident
    when :multiple_choice, :checkboxes
      question_options.sample
    end
  end
end
