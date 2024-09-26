# frozen_string_literal: true

class Dragnet::ReplyGenerator < Dragnet::ActiveRecordGenerator
  def call(*)
    s = attributes.fetch(:survey) { raise 'A survey attribute is required' }

    Reply.new(survey: s) do |r|
      r.created_at   = attributes.fetch(:created_at) { Faker::Date.between(from: 2.years.ago, to: Date.today) }
      r.updated_at   = attributes.fetch(:updated_at) { r.created_at }
      r.submitted    = attributes.fetch(:submitted) { Faker::Boolean.boolean(true_ratio: 0.8) }
      r.submitted_at = r.created_at if r.submitted?
      r.ahoy_visit   = attributes.fetch(:ahoy_visit, nil)

      generate_answers(s, r)
    end
  end

  private

  def generate_answers(survey, reply)
    survey.questions.each do |question|
      next unless question.required? || Faker::Boolean.boolean(true_ratio: 0.3)

      reply.answers << Answer[survey:, reply:, question:, question_type_id: question.question_type_id].generate
    end
  end
end
