# frozen_string_literal: true

class SubmissionRequestController < ApplicationController
  layout 'external'

  def new
    if already_submitted?
      redirect_to survey_forbidden_path, alert: t('replies.already_submitted', survey_name: survey.name)
    elsif not_permitted?
      redirect_to survey_forbidden_path, alert: t('replies.not_permitted')
    else
      redirect_to edit_reply_path(reply)
    end
  end

  def not_found
    render status: :not_found
  end

  def forbidden
    render status: :forbidden
  end

  private

  def reply
    if revisit?
      survey.existing_reply(current_visit.visitor_token)
    else
      survey.replies.create!
    end
  end

  def already_submitted?
    survey.reply_completed?(current_visit.visitor_token)
  end

  def not_permitted?
    !survey.can_submit_reply?(current_user)
  end

  def revisit?
    survey.reply_created?(current_visit.visitor_token)
  end

  def current_visit
    ahoy.visit
  end

  def survey
    @survey ||= Dragnet::Survey.find_by_short_id!(params.require(:survey_id))
  end
end
