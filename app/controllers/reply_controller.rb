class ReplyController < ApplicationController
  def new
    reply = Reply.create!(params.assert_keys(:survey_id))

    redirect_to edit_reply_path(reply)
  end

  def edit
    @reply = replies.find(params[:id])
  end

  def update
    @reply = replies.find(params[:id])

    if @reply.update(update_params)
      redirect_to reply_successful_path(@reply)
    else
      render :edit
    end
  end

  def success
    @reply = replies.find(params[:id])
  end

  private

  def replies
    Reply.includes(:survey, :answers)
  end

  def update_params
    params.require(:reply).permit(
      :survey_id,
      answers_attributes: %i[survey_id question_id question_type_id question_option_id short_text_value long_text_value]
    )
  end
end
