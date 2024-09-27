# frozen_string_literal: true

class RepliesController < ApplicationController
  layout 'external'

  def edit
    if reply.can_edit_reply?(current_user)
      tracker.view_submission_form(reply)
      render :edit, locals: { reply: }
    else
      redirect_to root_path, alert: t('replies.not_permitted')
    end
  end

  def update
    if !reply.can_update_reply?(current_user)
      redirect_to root_path, alert: t('replies.not_permitted')
    elsif reply.update(reply_params)
      tracker.update_submission_form(reply)
      redirect_to edit_reply_path(reply)
    else
      render :edit, locals: { reply: }
    end
  end

  def submit
    if !reply.can_complete_reply?(current_user)
      redirect_to root_path, alert: t('replies.not_permitted')
    elsif reply.submit(reply_params)
      tracker.complete_submission_form(reply)
      redirect_to complete_reply_path(reply.id)
    else
      render :edit, locals: { reply: }
    end
  end

  def success
    render :success, locals: { reply: }
  end

  def preview
    survey = Dragnet::Survey.find(params[:survey_id])

    if survey.can_preview?(current_user)
      render :edit, locals: { reply: survey.replies.build }
    else
      redirect_to root_path, alert: t('replies.not_permitted')
    end
  end

  private

  def tracker
    @tracker ||= Dragnet::ReplyTracker.new(ahoy)
  end

  def reply
    @reply ||= replies.find(params[:id])
  end

  def replies
    Dragnet::Reply.includes(:survey, :answers, questions: [:question_type])
  end

  def reply_params
    params.require(:reply).permit(*reply.submission_parameters)
  end
end
