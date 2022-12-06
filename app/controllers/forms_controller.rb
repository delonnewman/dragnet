class FormsController < ApplicationController
  def index
    @forms = Form.all # TODO: get the current user's surveys
  end

  def new
    form = Form.init(User.first).tap(&:save!)

    redirect_to edit_form_path(form)
  end

  def results
    @form = Form.find(params[:form_id])

    render :results, layout: 'form'
  end

  def edit
    @form = Form.find(params[:id])

    render :edit, layout: 'form'
  end

  def delete
    Form.find(params[:id]).delete

    redirect_to root_path
  end
end
