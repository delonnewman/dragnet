# frozen_string_literal: true

class DispatchSubmissionRequest < ApplicationInteractor
  delegate :survey, :policy, :visit, :ahoy, :params, :reply, to: :context

  PERMISSION_ERROR = "You don't have permission to reply to this survey"
  SUBMITTED_ERROR  = "It seems you've already submitted a reply to survey %s"

  def call
    fail!(error: format(SUBMITTED_ERROR, survey.name.inspect)) if policy.visitor_reply_submitted?(survey, visit)
    fail!(error: PERMISSION_ERROR) unless policy.can_create_reply?(survey)

    if policy.can_preview_survey?(survey, params)
      context.reply   = survey.replies.build
      context.preview = true
    elsif policy.visitor_reply_created?(survey, visit)
      context.reply = survey.ahoy_visits.of_visitor(visit.visitor_token).first.reply
      ahoy.track 'view-submission-form', reply_id: reply.id, survey_id: survey.id
    else
      context.reply = Reply.create!(survey: survey)
      ahoy.track 'view-submission-form', reply_id: reply.id, survey_id: survey.id
    end
  end
end
