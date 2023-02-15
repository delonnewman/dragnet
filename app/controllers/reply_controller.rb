class ReplyController < ApplicationController
  layout 'external'

  def new
    survey = Survey.find_by_short_id!(params.require(:survey_id))

    if ReplySubmissionPolicy.for(current_user).can_create_reply?(survey)
      reply = Reply.create!(survey: survey)
      redirect_to edit_reply_path(reply)
    else
      redirect_to root_path, flash: "You don't have permission to reply to this survey"
    end
  end

  def edit
    reply = replies.find(params[:id])
    if ReplySubmissionPolicy.for(current_user).can_edit_reply?(reply)
      render :edit, locals: { reply: reply }
    else
      redirect_to root_path, flash: "You don't have permission to reply to this survey"
    end
  end

  def update
    reply = replies.find(params[:id])

    if !ReplySubmissionPolicy.for(current_user).can_update_reply?(reply)
      redirect_to root_path, flash: "You don't have permission to reply to this survey"
    elsif reply.submit!(reply_params)
      redirect_to reply_success_path(reply)
    else
      render :edit, locals: { reply: reply }
    end
  end

  def success
    render :success, locals: { reply: replies.find(params[:reply_id]) }
  end

  private

  def replies
    Reply.includes(:survey, :answers, questions: [:question_type])
  end

  def reply_params
    params.require(:reply)
  end
end
