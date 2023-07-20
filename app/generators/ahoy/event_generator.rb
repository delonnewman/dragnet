# frozen_string_literal: true

module Ahoy
  class EventGenerator < Dragnet::ActiveRecordGenerator
    def call(*)
      visit     = attributes.fetch(:visit)     { raise 'A visit attribute is required' }
      survey_id = attributes.fetch(:survey_id) { raise 'A survey_id attribute is required' }
      reply_id  = attributes.fetch(:reply_id)  { raise 'A reply_id attribute is required' }

      Event.new(visit: visit) do |e|
        e.user = attributes.fetch(:user) { Faker::Boolean.boolean ? User.generate : nil }
        e.name = attributes.fetch(:name) { ReplyTracker::EVENT_TAGS.values.sample }
        e.properties = { survey_id: survey_id, reply_id: reply_id }
      end
    end
  end
end
