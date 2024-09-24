# frozen_string_literal: true

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
      format.json    { render json: reply_submission.submission_data }
      format.transit { render body: transit(reply_submission.submission_data) }
    end
  end

  def preview
    respond_to do |format|
      format.html    { render plain: form_code(new_reply) }
      format.json    { render json: reply_submission(new_reply).submission_data }
      format.transit { render body: transit(reply_submission(new_reply).submission_data) }
    end
  end

  private

  def submission_params(reply)
    params.require(:reply).permit(*reply.submission_parameters)
  end

  def form_code(reply)
    survey_form_code(reply.survey_id, request.base_url)
  end

  def reply_submission(reply = self.reply)
    Dragnet::ReplySubmissionPresenter.new(reply)
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
    { reply_id: newly_saved_reply.id, survey_id: newly_saved_reply.survey_id }
  end

  def reply
    Dragnet::Reply
      .includes(:survey, questions: %i[question_type question_options])
      .find(params[:id])
  end
end
