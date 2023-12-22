# frozen_string_literal: true

class SurveysController < ApplicationController
  include Authenticated
  include QRCodeHelper

  layout 'survey'

  def index; end

  def show
    presenter = Dragnet::SurveyPresenter.new(survey, params)

    render :show, locals: { report: presenter.stats_report, survey: presenter }
  end

  def new
    survey = Dragnet::Survey.create!(author: current_user)

    redirect_to edit_survey_path(survey)
  end

  def edit
    render :edit, locals: { survey: survey }
  end

  def destroy
    survey.tap(&:delete)

    redirect_to root_path, notice: "You've deleted #{survey.name.inspect}"
  end

  def copy
    copy = survey.copy!

    redirect_to edit_survey_path(copy)
  end

  def preview
    render :preview, locals: { survey: Dragnet::SurveyPresenter.new(survey, params) }
  end

  def settings
    render :settings, locals: { survey: survey }
  end

  def open
    survey.open!

    render partial: 'workspace/survey_card', locals: { survey: survey }
  end

  def close
    survey.close!

    render partial: 'workspace/survey_card', locals: { survey: survey }
  end

  def share
    render :share, locals: { survey: Dragnet::SurveyPresenter.new(survey, params) }
  end

  def qrcode
    respond_to do |format|
      format.html { render :qrcode, locals: { survey: survey } }
      format.png  { send_qrcode_data survey, format: :png }
      format.svg  { send_qrcode_data survey, format: :svg }
    end
  end

  private

  def survey
    @survey ||= Dragnet::Survey.find(survey_id)
  end

  def survey_id
    params.fetch(:id) do
      params.fetch(:survey_id) do
        raise 'id or survey_id are required'
      end
    end
  end
end