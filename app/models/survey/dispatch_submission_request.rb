# frozen_string_literal: true

class Survey::DispatchSubmissionRequest < Dragnet::Command
  alias survey subject

  PERMISSION_ERROR = "You don't have permission to reply to this survey"
  SUBMITTED_ERROR  = "It seems you've already submitted a reply to survey %s"

  def call(user:, visit:, tracker:, wants_preview:)
    fail!(error: format(SUBMITTED_ERROR, survey.name.inspect)) if     survey.visitor_reply_submitted?(visit)
    fail!(error: PERMISSION_ERROR)                             unless user.can_create_reply?(survey)

    if user.can_preview_survey?(survey, wants_preview: wants_preview)
      result.reply   = survey.replies.build
      result.preview = true
    elsif survey.visitor_reply_created?(survey, visit)
      result.reply = survey.ahoy_visits.of_visitor(visit.visitor_token).first.reply
      tracker.view_submission_form(result.reply)
    else
      result.reply = Reply.create!(survey: survey)
      tracker.view_submission_form(result.reply)
    end
  end
end
