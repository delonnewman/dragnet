# frozen_string_literal: true

class DataGridController < ApplicationController
  layout 'survey'

  def show
    respond_to do |format|
      format.html do
        render :show, locals: { survey: DataGridPresenter.new(survey, params) }
      end
    end
  end

  private

  def survey
    Survey.includes(:replies, questions: [:question_type]).find(params[:survey_id])
  end
end
