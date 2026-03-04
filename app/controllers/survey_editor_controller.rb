# frozen_string_literal: true

class SurveyEditorController < ApplicationController
  private

  def survey
    Dragnet::Survey.whole.find(params[:survey_id])
  end

  def latest_edit
    Dragnet::SurveyEdit.latest(survey)
  end

  def new_edit(data)
    Dragnet::SurveyEdit.create_with!(survey, data:)
  end

  def survey_editing(s = survey)
    Dragnet::SurveyEditingPresenter.new(s)
  end
end
