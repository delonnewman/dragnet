# frozen_string_literal: true

# Provides reply submission data to the submitter frontend
class ReplySubmissionController < EndpointController
  include FormSubmissionHelper

  # TODO: Add server-side check based on visit-token to avoid creating duplicate replies
  def new
    respond_to do |format|
      format.html    { render plain: form_code(newly_saved_reply) }
      format.json    { render json: newly_saved_reply_data }
      format.transit { render body: transit(newly_saved_reply_data) }
    end
  end

  def show
    respond_to do |format|
      format.html    { render plain: form_code(reply) }
      format.json    { render json: reply_submission_data(reply) }
      format.transit { render body: transit(reply_submission_data(reply)) }
    end
  end

  def preview
    respond_to do |format|
      format.html    { render plain: form_code(new_reply) }
      format.json    { render json: reply_submission_data(new_reply) }
      format.transit { render body: transit(reply_submission_data(new_reply)) }
    end
  end

  private

  def form_code(reply)
    survey_form_code(reply.survey_id, request.base_url)
  end

  def reply_submission_data(reply)
    Dragnet::ReplySubmissionPresenter.new(reply).submission_data.merge(authenticity_token:)
  end

  def new_reply
    @new_reply ||= Dragnet::Survey.find(params[:survey_id]).replies.build
  end

  def newly_saved_reply
    reply = new_reply
    return reply if reply.persisted?

    reply.save!
    reply
  end

  def newly_saved_reply_data
    { reply_id: newly_saved_reply.id, survey_id: newly_saved_reply.survey_id, authenticity_token: }
  end

  def authenticity_token
    session[:_csrf_token]
  end

  def reply
    Dragnet::Reply
      .includes(:survey, questions: %i[question_options])
      .find(params[:id])
  end
end
