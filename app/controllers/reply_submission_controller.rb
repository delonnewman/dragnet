# frozen_string_literal: true

class ReplySubmissionController < EndpointController
  def show
    respond_to do |format|
      format.transit { render body: transit(reply_submission.submission_data) }
    end
  end

  def preview
    respond_to do |format|
      format.transit do
        reply = Reply.new(survey: Survey.find(params[:survey_id]))
        render body: transit(reply_submission(reply).submission_data)
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

  def reply
    Reply
      .includes(:survey, questions: %i[question_type question_options followup_questions])
      .find(params[:id])
  end
end
