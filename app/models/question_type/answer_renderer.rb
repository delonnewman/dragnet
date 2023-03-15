# frozen_string_literal: true

class QuestionType::AnswerRenderer
  attr_reader :perspective, :question_type

  # @param [QuestionType::Perspective] perspective
  def initialize(question_type, perspective)
    @question_type = question_type
    @perspective = perspective
  end

  def with_perspective(perspective, &block)
    r = new(question_type, perspective)
    block.call(r) if block_given?
    r
  end

  def render(answers, **options)
    perspective.render(question_type, answers, **options)
  end
end
