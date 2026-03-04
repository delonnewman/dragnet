# frozen_string_literal: true

class SurveyEditorController < ApplicationController
  layout false

  private

  def survey
    Dragnet::Survey.whole.find(params[:survey_id])
  end

  def editor
    Dragnet::SurveyEditorPresenter.new(survey)
  end
end
