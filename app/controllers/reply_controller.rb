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

    if current_user.can_edit_reply?(reply)
      render :edit, locals: { reply: reply }
    else
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    end
  end

  def update
    reply = replies.find(params[:id])

    if !current_user.can_update_reply?(reply)
      redirect_to root_path, alert: "You don't have permission to reply to this survey"
    elsif reply.submit!(reply_params)
      tracker.update_submission_form(reply)
      redirect_to reply_success_path(reply)
    else
      render :edit, locals: { reply: reply }
    end
  end

  def submit
    reply = Dragnet::Reply.find(params[:id])

    if reply.update(submission_params(reply))
      redirect_to reply_success_path(reply.id)
    else
      render :edit, locals: { reply: reply }
    end
  end

  def success
    reply = replies.find(params[:reply_id])

    tracker.complete_submission_form(reply)
    render :success, locals: { reply: reply }
  end

  private

  # rubocop: disable Rails/DynamicFindBy
  def dispatch_submission_request
    Dragnet::Survey.find_by_short_id!(params.require(:survey_id)).dispatch_submission_request(
      wants_preview: params[:preview].present?,
      user:          current_user,
      visit:         current_visit,
      tracker:       tracker
    )
  end

  # rubocop: enable Rails/DynamicFindBy

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