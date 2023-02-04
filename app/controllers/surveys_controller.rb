class SurveysController < ApplicationController
  include Authenticated

  def index
    @surveys = current_user.surveys.order(:name) # TODO: get the current user's surveys
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

  def delete
    Survey.find(params[:id]).delete

    redirect_to root_path
  end
end
