class SurveysController < ApplicationController
  def index
    @surveys = Survey.all # TODO: get the current user's surveys
  end

  def new
    survey = Survey.create!(name: "Untitled Survey", author: User.first)

    redirect_to edit_survey_path(survey)
  end

  def edit
    @survey = Survey.find(params[:id])
  end
end
