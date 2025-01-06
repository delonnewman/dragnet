# frozen_string_literal: true

class Dragnet::AnswerValue < Dragnet::ParameterizedGenerator
  attr_reader :question

  def initialize(question:)
    super()
    @question = question
  end

  def call
    type = question.question_type.ident

    case type
    when :text
      ShortAnswer.generate
    when :long_text
      LongAnswer.generate
    when :choice
      Dragnet::QuestionOptionAnswer[question].generate
    when :integer
      rand(100)
    when :decimal
      (rand(100) + rand).round(rand(5))
    when :time, :date, :date_and_time
      time = Faker::Time.between(from: 3.months.ago, to: Time.zone.now)
      return time.to_date if type == :date
      return time.to_datetime if type == :date_and_time
      time
    when :boolean
      Faker::Boolean.boolean
    when :email
      Email.generate
    when :phone
      Phone.generate
    else
      raise "Don't know how to generate an answer for #{question.question_type.ident.inspect}"
    end
  end
end
