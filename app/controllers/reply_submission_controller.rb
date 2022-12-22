# frozen_string_literal: true

class ReplySubmissionController < APIController
  def show
    render json: transit(reply.survey.projection), content_type: 'application/transit+json'
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
end
