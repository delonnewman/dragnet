# frozen_string_literal: true

class ReplyTracker
  EVENT_TAGS = {
    view:     'view-submission-form',
    update:   'update-submission-form',
    complete: 'complete-submission-form'
  }.freeze

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
