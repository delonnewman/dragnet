# frozen_string_literal: true

class ReplyController::ReplyTracker
  attr_reader :ahoy


  # @param [Ahoy::Tracker] ahoy_tracker
  def initialize(ahoy_tracker)
    @ahoy = ahoy_tracker
  end

  def view_submission_form(reply)
    ahoy.track 'view-submission-form', reply_id: reply.id, survey_id: reply.survey_id
  end

  def update_submission_form(reply)
    ahoy.track 'update-submission-form', reply_id: reply.id, survey_id: reply.survey_id
  end

  def complete_submission_form(reply)
    ahoy.track 'complete-submission-form', reply_id: reply.id, survey_id: reply.survey_id
  end
end
