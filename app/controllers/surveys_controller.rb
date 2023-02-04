class SurveysController < ApplicationController
  include Authenticated

  def index
    @surveys = current_user.surveys.order(:name) # TODO: get the current user's surveys
  end

  def show
    @survey = DataGridPresenter.new(Survey.find(params[:id]), params)
  end

  def new
    survey = Survey.create!(author: User.first)

    redirect_to edit_survey_path(survey)
  end

  def results
    @survey = Survey.find(params[:survey_id])

    render :results, layout: 'survey'
  end

  def edit
    @survey = Survey.find(params[:id])

    render :edit, layout: 'survey'
  end

  def copy
    copy = Survey.find(params[:survey_id]).copy!
    # TODO: add error handling

    render partial: 'surveys/card', locals: { survey: copy }
  end

  def destroy
    Survey.find(params[:id]).delete

    render html: ""
  end
end
