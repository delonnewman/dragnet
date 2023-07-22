# frozen_string_literal: true

class ReplySubmissionController < EndpointController
  # TODO: Remove this once security is in place
  skip_before_action :verify_authenticity_token, only: %i[show new preview]

  def new
    respond_to do |format|
      format.js      { render js: form_code(newly_saved_reply) }
      format.json    { render json: newly_saved_reply_data }
      format.transit { render body: transit(newly_saved_reply_data) }
    end
  end

  def show
    respond_to do |format|
      format.js      { render js: form_code(reply) }
      format.json    { render json: reply_submission.submission_data }
      format.transit { render body: transit(reply_submission.submission_data) }
    end
  end

  def preview
    respond_to do |format|
      format.js      { render form_code(new_reply) }
      format.json    { render json: reply_submission(new_reply).submission_data }
      format.transit { render body: transit(reply_submission(new_reply).submission_data) }
    end
  end

  private

  def submission_params(reply)
    params.require(:reply).permit(*reply.submission_parameters)
  end

  def reply_submission(reply = self.reply)
    ReplySubmissionPresenter.new(reply)
  end

  def new_reply
    @new_reply ||= Reply.new(survey: Survey.find(params[:survey_id]))
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
    Reply
      .includes(:survey, questions: %i[question_type question_options followup_questions])
      .find(params[:id])
  end

  def form_code(reply)
    erb = form_erb

    eval(Erubi::Engine.new(erb).src)
  end

  def form_erb
    Rails.root.join('app/views/reply/form.js.erb').read
  end
end
