# frozen_string_literal: true

class RepliesController < ApplicationController
  layout 'external'

  before_action only: %i[edit] do
    forbid unless reply.can_edit_reply?(current_user)
  end

  def edit
    tracker.view_submission_form(reply)
    render :edit, locals: { reply: }
  end

  before_action only: %i[update] do
    forbid unless reply.can_update_reply?(current_user)
  end

  def update
    if reply.update(reply_params)
      tracker.update_submission_form(reply)
      redirect_to edit_reply_path(reply)
    else
      render :edit, locals: { reply: }
    end
  end

  before_action only: %i[submit] do
    forbid unless reply.can_complete_reply?(current_user)
  end

  def submit
    if reply.submit(reply_params)
      tracker.complete_submission_form(reply)
      redirect_to complete_reply_path(reply.id)
    else
      render :edit, locals: { reply: }
    end
  end

  before_action only: %i[complete] do
    forbid unless reply.can_complete_reply?(current_user)
  end

  def complete
    render :success, locals: { reply: }
  end

  before_action only: %i[preview] do
    forbid unless survey.can_preview?(current_user)
  end

  def preview
    render :edit, locals: { reply: survey.replies.build }
  end

  private

  def forbid
    redirect_to survey_forbidden_path, alert: t('replies.not_permitted')
  end

  def tracker
    @tracker ||= Dragnet::ReplyTracker.new(ahoy)
  end

  def survey
    @survey ||= Dragnet::Survey.whole.find(params[:survey_id])
  end

  def reply
    @reply ||= replies.find(params[:id])
  end

  def replies
    Dragnet::Reply.includes(:survey, :answers, questions: [:question_type])
  end

  def reply_params
    params.require(:reply).permit(*reply.submission_parameters.reply_attributes)
  end
end
