# frozen_string_literal: true

class WorkspaceController < ApplicationController
  include Authenticated

  def index
    overview = OverviewPresenter.new(current_user)

    render :index, locals: { overview: overview }
  end

  def surveys
    listing = SurveyListingPresenter.new(current_user, params)

    render :surveys, locals: { listing: listing }
  end

  def open_survey
    survey = Survey.find(params[:survey_id]).open!

    render partial: 'workspace/survey_card', locals: { survey: survey }
  end

  def close_survey
    survey = Survey.find(params[:survey_id]).close!

    render partial: 'workspace/survey_card', locals: { survey: survey }
  end
end
