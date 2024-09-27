# frozen_string_literal: true

class SubmissionRequestController < ApplicationController
  layout 'external'

  def new
    if already_submitted?
      redirect_to root_path, alert: t('replies.already_submitted', survey_name: survey.name)
    elsif not_permitted?
      redirect_to root_path, alert: t('replies.not_permitted')
    else
      redirect_to edit_reply_path(reply)
    end
  end

  private

  def reply
    if revisit?
      tracker.existing_reply(survey, current_visit.visitor_token)
    else
      survey.replies.create!
    end
  end

  def survey
    @survey ||= Dragnet::Survey.find_by_short_id!(params.require(:survey_id))
  end

  def already_submitted?
    tracker.reply_completed?(survey, current_visit.visitor_token)
  end

  def not_permitted?
    !survey.can_submit_reply?(current_user)
  end

  def revisit?
    tracker.reply_created?(survey, current_visit.visitor_token)
  end

  def tracker
    @tracker ||= Dragnet::ReplyTracker.new(ahoy)
  end

  def current_visit
    ahoy.visit
  end
end
