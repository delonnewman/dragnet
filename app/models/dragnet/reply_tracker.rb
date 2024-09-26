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

    # @param [Ahoy::Tracker] ahoy_tracker
    def initialize(ahoy_tracker)
      @ahoy = ahoy_tracker
    end

    # @param [Reply] reply
    # @return [void]
    def view_submission_form(reply)
      track EVENT_TAGS[:view], reply_id: reply.id, survey_id: reply.survey_id
    end

    # @param [Reply] reply
    # @return [void]
    def update_submission_form(reply)
      track EVENT_TAGS[:update], reply_id: reply.id, survey_id: reply.survey_id
    end

    # @param [Reply] reply
    # @return [void]
    def complete_submission_form(reply)
      track EVENT_TAGS[:complete], reply_id: reply.id, survey_id: reply.survey_id
    end

    private

    attr_reader :ahoy

    delegate :track, to: :ahoy
  end
end
