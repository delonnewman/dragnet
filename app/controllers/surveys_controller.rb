class SurveysController < ApplicationController
  def index
    @surveys = Survey.all # TODO: get the current user's surveys
  end
end
