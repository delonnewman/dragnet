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

  def submit
    Reply.create!(submission_params)
  end

  private

  def submission_params
    params.require(:reply)
  end

  def reply_submission(r = reply)
    ReplySubmissionPresenter.new(r)
  end

  def reply
    Reply
      .includes(:survey, questions: [:question_type, :question_options, :followup_questions])
      .find(params[:id])
  end
end
