class SurveysController < ApplicationController
  def index
    @surveys = Survey.all # TODO: get the current user's surveys
  end

  def new
    survey = Survey.init(author: User.first).tap(&:save!)

    redirect_to edit_survey_path(survey)
  end

  def edit
    @survey = Survey.find(params[:id])
  end
end
