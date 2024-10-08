# frozen_string_literal: true

class Dragnet::AnswerValue < Dragnet::ParameterizedGenerator
  attr_reader :question

  def initialize(question:)
    super()
    @question = question
  end

  def call
    case question.question_type.ident
    when :text
      question.settings.long_answer? ? LongAnswer.generate : ShortAnswer.generate
    when :choice
      QuestionOptionAnswer[question].generate
    when :number
      Random.rand(100)
    when :time
      Faker::Time.between(from: 3.months.ago, to: Time.zone.now)
    when :boolean
      Faker::Boolean.boolean
    else
      raise "Don't know how to generate an answer for #{question.question_type.ident.inspect}"
    end
  end
end
