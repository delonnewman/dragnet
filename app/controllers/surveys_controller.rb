# frozen_string_literal: true

class SurveysController < ApplicationController
  include Authenticated

  layout 'survey'

  def index; end

  def show
    survey = Survey.find(params[:id])
    report = StatsReport.new(survey)

    render :show, locals: { report: report, survey: survey }
  end

  def new
    survey = Survey.create!(author: User.first)

    redirect_to edit_survey_path(survey)
  end

  def edit
    render :edit, locals: { survey: Survey.find(params[:id]) }
  end

  def destroy
    survey = Survey.find(params[:id]).tap(&:delete)

    redirect_to root_path, notice: "You've deleted #{survey.name.inspect}"
  end

  def copy
    copy = Survey.find(params[:survey_id]).copy!

    redirect_to edit_survey_path(copy)
  end

  def preview
    survey = Survey.find(params[:survey_id])

    render :preview, locals: { survey: survey }
  end

  def settings
    render :settings, locals: { survey: Survey.find(params[:survey_id]) }
  end
end
