# frozen_string_literal: true

class AnswerGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey)    { raise 'A survey attribute is required' }
    r = attributes.fetch(:reply)     { raise 'A reply attribute is required'  }
    q = attributes.fetch(:question)  { raise 'A question attribute is required' }

    # TODO: Add support for multiple choice
    Answer.new(survey: s, reply: r, question: q) do |a|
      a.question_type = q.question_type
      a.value = value(q)
    end
  end

  def value(question)
    case question.question_type.ident
    when :text
      ShortAnswer.generate
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
