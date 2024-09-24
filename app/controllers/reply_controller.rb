# frozen_string_literal: true

class ReplyController < ApplicationController
  layout 'external'

  def new
    result = dispatch_submission_request

    if result.failure?
      redirect_to root_path, alert: result.error
    elsif result.preview?
      render :edit, locals: { reply: result.reply }
    else
      redirect_to edit_reply_path(result.reply)
    end
  end

  def edit
    reply = replies.find(params[:id])

    if reply.can_edit_reply?(current_user)
      render :edit, locals: { reply: }
    else
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    end
  end

  def update
    reply = replies.find(params[:id])

    if !reply.can_update_reply?(current_user)
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    elsif reply.submit!(reply_params)
      tracker.update_submission_form(reply)
      redirect_to reply_success_path(reply)
    else
      render :edit, locals: { reply: }
    end
  end

  def submit
    reply = replies.find(params[:id])

    if !reply.can_complete_reply?(current_user)
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    elsif reply.update(submission_params(reply))
      redirect_to reply_success_path(reply.id)
    else
      render :edit, locals: { reply: }
    end
  end

  def success
    reply = replies.find(params[:reply_id])

    tracker.complete_submission_form(reply)
    render :success, locals: { reply: }
  end

  private

  def dispatch_submission_request
    Dragnet::Survey.find_by_short_id!(params.require(:survey_id)).dispatch_submission_request(
      wants_preview: params[:preview].present?,
      user: current_user,
      visit: current_visit,
      tracker:
    )
  end

  def current_visit
    Ahoy.instance.visit_or_create
  end

  def tracker
    @tracker ||= Dragnet::ReplyTracker.new(ahoy)
  end

  def replies
    Dragnet::Reply.includes(:survey, :answers, questions: [:question_type])
  end

  # TODO: create a strong parameters generator based on survey schema
  def reply_params
    params.require(:reply)
  end
end
