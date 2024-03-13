# frozen_string_literal: true

class DataGridController < ApplicationController
  include Authenticated

  layout 'survey'

  def show
    respond_to do |format|
      format.html do
        render :show, locals: { grid: presenter }
      end
      format.csv do
        render_file :show, export_name(presenter.survey), locals: { grid: presenter }
      end
      format.xlsx do
        render_file :show, export_name(presenter.survey), locals: { grid: presenter }
      end
    end
  end

  def rows
    render partial: 'data_grid/rows', locals: { grid: presenter }
  end

  def table
    render partial: 'data_grid/table', locals: { grid: presenter }
  end

  private

  def render_file(view, filename, **options)
    render view, **options
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
  end

  def export_name(survey)
    "#{survey.slug}-#{Dragnet::Utils.slug(Time.zone.now)}.#{params[:format]}"
  end

  def presenter
    Dragnet::DataGridPresenter.new(Dragnet::DataGrid.ensure!(survey, current_user), data_grid_params)
  end

  def survey
    Dragnet::Survey.includes(questions: [:question_type, :question_options]).find(params[:survey_id])
  end

  def data_grid_params
    params.permit(:page, :items, :sort_by, :sort_direction, :created_at, :user_id, filter_by: {})
  end
end
