# frozen_string_literal: true

class ReplyController < ApplicationController
  layout 'external'

  # rubocop: disable Rails/DynamicFindBy
  def new
    result = DispatchSubmissionRequest.call(
      survey: Survey.find_by_short_id!(params.require(:survey_id)),
      policy: submission_policy,
      visit:  Ahoy.instance.visit_or_create,
      ahoy:   ahoy,
      params: params
    )

    if result.failure?
      redirect_to root_path, alert: result.error
    elsif result.preview
      render :edit, locals: { reply: result.reply }
    else
      redirect_to edit_reply_path(result.reply)
    end
  end
  # rubocop: enable Rails/DynamicFindBy

  def edit
    reply = replies.find(params[:id])

    if submission_policy.can_edit_reply?(reply)
      render :edit, locals: { reply: reply }
    else
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    end
  end

  def update
    reply = replies.find(params[:id])

    if !submission_policy.can_update_reply?(reply)
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    elsif reply.submit!(reply_params)
      ahoy.track 'update-submission-form', reply_id: reply.id, survey_id: survey.id
      redirect_to reply_success_path(reply)
    else
      render :edit, locals: { reply: reply }
    end
  end

  def success
    reply = replies.find(params[:reply_id])

    ahoy.track 'complete-submission-form', reply_id: reply.id, survey_id: reply.survey_id
    render :success, locals: { reply: reply }
  end

  private

  def submission_policy
    @submission_policy ||= ReplySubmissionPolicy.for(current_user)
  end

  def replies
    Reply.includes(:survey, :answers, questions: [:question_type])
  end

  # TODO: create a strong parameters generator based on survey schema
  def reply_params
    params.require(:reply)
  end
end
