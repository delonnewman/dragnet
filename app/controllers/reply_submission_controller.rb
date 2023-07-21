# frozen_string_literal: true

class ReplySubmissionController < EndpointController
  skip_before_action :verify_authenticity_token, only: %i[show new]

  def new
    respond_to do |format|
      format.js do
        new_reply.save!
        render 'reply/form', locals: { reply: new_reply }
      end
    end
  end

  def show
    respond_to do |format|
      format.transit { render body: transit(reply_submission.submission_data) }
      format.js { render 'reply/form', locals: { reply: reply } }
    end
  end

  def preview
    respond_to do |format|
      format.transit do
        render body: transit(reply_submission(new_reply).submission_data)
      end
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

  def reply
    Reply
      .includes(:survey, questions: %i[question_type question_options followup_questions])
      .find(params[:id])
  end
end
