# frozen_string_literal: true

class Dragnet::AnswerGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey)    { raise 'A survey attribute is required' }
    r = attributes.fetch(:reply)     { raise 'A reply attribute is required'  }
    q = attributes.fetch(:question)  { raise 'A question attribute is required' }

    # TODO: Add support for multiple choice
    Answer.new(survey: s, reply: r, question: q) do |a|
      a.question_type = q.question_type
      a.value = Dragnet::AnswerValue[question: q].generate
    end
  end
end
