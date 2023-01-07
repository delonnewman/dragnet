# frozen_string_literal: true

class ReplySubmissionController < EndpointController
  def show
    respond_to do |format|
      format.transit { render body: transit(reply_submission.submission_data) }
    end
  end

  def submit
    Reply.create!(read_transit(request.body))
  end

  private

  def reply
    Reply
      .includes(:survey, :answers, questions: [:question_type])
      .find(params[:id])
  end

  def reply_submission(r = reply)
    ReplySubmissionPresenter.new(r)
  end
end
