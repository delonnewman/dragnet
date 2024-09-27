# frozen_string_literal: true

module Dragnet
  class ReplyTracker
    EVENT_TAGS = {
      request: 'Submission Request',
      view: 'View Submission Form',
      update: 'Update Submission Form',
      complete: 'Complete Submission Form',
    }.freeze

    def self.event_tags
      EVENT_TAGS.keys
    end

    def self.event_names
      EVENT_TAGS.values
    end

    def self.event_name(tag)
      EVENT_TAGS.fetch(tag) do
        raise "unknown event tag: #{tag.inspect}"
      end
    end

    delegate :event_name, to: 'self.class'

    # @param [Ahoy::Tracker] ahoy_tracker
    def initialize(ahoy_tracker)
      @ahoy = ahoy_tracker
    end

    # @param [Reply] reply
    # @return [void]
    def request_submission_form(reply)
      track_event :request, reply
    end

    # @param [Reply] reply
    # @return [void]
    def view_submission_form(reply)
      track_event :view, reply
    end

    # @param [Reply] reply
    # @return [void]
    def update_submission_form(reply)
      track_event :update, reply
    end

    # @param [Reply] reply
    # @return [void]
    def complete_submission_form(reply)
      track_event :complete, reply
    end

    # @param [Symbol] tag
    # @param [Reply] reply
    # @return [void]
    def track_event(tag, reply)
      reply.ensure_visit(@ahoy.visit)
      @ahoy.track event_name(tag), reply.id, survey_id: reply.survey_id
    end
  end
end
