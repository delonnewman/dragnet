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

  def generate!(*other_attributes)
    reply = generate(*other_attributes)
    reply.save!
    create_ahoy_events(reply) if attributes.fetch(:create_ahoy_visit, false)
    reply
  end

  private

  def create_ahoy_events(reply)
    visit = Ahoy::Visit.generate!

    Ahoy::Event[name: ReplyTracker.event_name(:view), visit:, survey_id: reply.survey_id, reply_id: reply.id].generate!
    Ahoy::Event[name: ReplyTracker.event_name(:update), visit:, survey_id: reply.survey_id, reply_id: reply.id].generate!
    if reply.submitted?
      Ahoy::Event[name: ReplyTracker.event_name(:complete), visit:, survey_id: reply.survey_id, reply_id: reply.id].generate!
    end

    reply.update!(ahoy_visit: visit)
  end

  def generate_answers(survey, reply)
    survey.questions.each do |question|
      next unless question.required? || Faker::Boolean.boolean(true_ratio: 0.3)

      reply.answers << Answer[survey:, reply:, question:].generate
    end
  end
end
