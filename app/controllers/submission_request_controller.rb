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
      survey.ahoy_visits.of_visitor(visitor_token).first.reply
    else
      survey.replies.create!
    end
  end

  def survey
    @survey ||= Dragnet::Survey.find_by_short_id!(params.require(:survey_id))
  end

  def already_submitted?
    survey.visitor_reply_submitted?(current_visit&.visitor_token)
  end

  def not_permitted?
    !survey.can_submit_reply?(current_user)
  end

  def revisit?
    survey.visitor_reply_created?(current_user)
  end

  def current_visit
    Ahoy.instance.visit_or_create
  end
end
