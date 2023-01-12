# frozen_string_literal: true

class ReplySubmissionController < EndpointController
  def show
    respond_to do |format|
      format.transit { render body: transit(reply_submission.submission_data) }
    end
  end

  def submit
    Reply.create!(submission_params)
  end

  private

  def submission_params
    params[:reply].permit!
  end

  def reply
    Reply
      .includes(:survey, :answers, questions: [:question_type])
      .find(params[:id])
  end

  def reply_submission(r = reply)
    ReplySubmissionPresenter.new(r)
  end
end
