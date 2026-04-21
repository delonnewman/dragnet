# frozen_string_literal: true

class SurveysController < ApplicationController
  include Authenticated

  layout 'survey'

  def show
    presenter = Dragnet::SurveyPresenter.new(whole_survey, params)

    render :show, locals: { report: presenter.stats_report, survey: presenter }
  end

  def create
    survey = Dragnet::Survey.create!(author: current_user)

    redirect_to edit_survey_path(survey)
  end

  def edit
    editor = Dragnet::SurveyEditorPresenter.new(survey)

    render :edit, locals: { editor: }
  end

  def update
    survey.edits.not_applied.apply
    editor = Dragnet::SurveyEditorPresenter.new(survey)

    render partial: 'survey_editor/tools', locals: { editor: }
  end

  def destroy
    survey.tap(&:delete)

    redirect_to root_path, notice: "You've deleted #{survey.name.inspect}"
  end

  def settings
    render :settings, locals: { survey: }
  end

  private

  def whole_survey
    Dragnet::Survey.whole.find(survey_id)
  end

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
