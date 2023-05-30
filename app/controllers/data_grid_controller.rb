# frozen_string_literal: true

class DataGridController < ApplicationController
  layout 'survey'

  def show
    respond_to do |format|
      format.html do
        render :show, locals: { survey: DataGridPresenter.new(survey, data_grid_params) }
      end
    end
  end

  def rows
    respond_to do |format|
      format.html do
        render partial: 'data_grid/rows', locals: { survey: DataGridPresenter.new(survey, data_grid_params) }
      end
    end
  end

  private

  def survey
    Survey.includes(:replies, questions: [:question_type]).find(params[:survey_id])
  end

  def data_grid_params
    params.permit(:page, :items, :sort_by, :sort_direction, :created_at, :user_id, filters: {})
  end
end
