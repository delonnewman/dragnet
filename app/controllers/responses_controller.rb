class ResponsesController < ApplicationController
  layout 'external'

  def new
    survey = Form.find_by_short_id!(params.require(:survey_id))
    reply  = Response.create!(form: survey)

    redirect_to edit_response_path(reply)
  end

  def edit
    @response = replies.find(params[:id])
  end

  def update
    @response = replies.find(params[:id])

    if @response.submit!(reply_params)
      redirect_to response_success_path(@response)
    else
      render :edit
    end
  end

  def success
    @response = replies.find(params[:reply_id])
  end

  private

  def replies
    Response.includes(:form, :items, fields: [:field_type])
  end

  def reply_params
    params.require(:response).permit!
  end
end
