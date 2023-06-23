# frozen_string_literal: true

class DataGridController < ApplicationController
  layout 'survey'

  def show
    presenter = DataGridPresenter.new(survey, data_grid_params)

    respond_to do |format|
      format.html do
        render :show, locals: { survey: presenter }
      end
      format.csv do
        render_file :show, export_name(presenter), locals: { survey: presenter }
      end
      format.xlsx do
        render_file :show, export_name(presenter), locals: { survey: presenter }
      end
    end
  end

  def rows
    render partial: 'data_grid/rows', locals: { survey: DataGridPresenter.new(survey, data_grid_params) }
  end

  def table
    render partial: 'data_grid/table', locals: { survey: DataGridPresenter.new(survey, data_grid_params) }
  end

  private

  def render_file(view, filename, **options)
    render view, **options
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
  end

  def export_name(survey)
    "#{Dragnet::Utils.slug(survey.name)}-#{Dragnet::Utils.slug(Time.zone.now)}.#{params[:format]}"
  end

  def survey
    Survey.includes(:replies, questions: [:question_type]).find(params[:survey_id])
  end

  def data_grid_params
    params.permit(:page, :items, :sort_by, :sort_direction, :created_at, :user_id, filter_by: {})
  end
end
