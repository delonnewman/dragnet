# frozen_string_literal: true

# Handles survey submission requests from users
class SubmissionRequestController < ApplicationController
  layout 'external'

  before_action :check_permissions, only: %i[new submit]

  def new
    redirect_to edit_reply_path(reply)
  end

  def submit
    if reply.submit(submission_params)
      render 'replies/success', locals: { reply: }
    else
      render body: reply.errors.full_messages.join(', '), status: :unproccessable_entity
    end
  end

  def not_found
    render status: :not_found
  end

  def forbidden
    render status: :forbidden
  end

  private

  def check_permissions
    if already_submitted?
      redirect_to survey_forbidden_path, alert: t('replies.already_submitted', survey_name: survey.name)
    elsif not_permitted?
      redirect_to survey_forbidden_path, alert: t('replies.not_permitted')
    end
  end

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

  def submission_params
    survey.submission_parameters.form_data(reply, params.permit(*survey.submission_parameters.form_attributes))
  end
end
