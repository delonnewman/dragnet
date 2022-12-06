class ResponsesController < ApplicationController
  layout 'external'

  def new
    form = Form.find_by_short_id!(params.require(:form_id))
    reply  = Response.create!(form: form)

    redirect_to edit_response_path(reply)
  end

  def edit
    @response = responses.find(params[:id])
  end

  def update
    @response = responses.find(params[:id])

    if @response.submit!(response_params)
      redirect_to response_success_path(@response)
    else
      render :edit
    end
  end

  def success
    @response = responses.find(params[:response_id])
  end

  private

  def responses
    Response.includes(:form, :items, fields: [:field_type])
  end

  def response_params
    params.require(:response).permit!
  end
end
