# frozen_string_literal: true

class DataGridController < ApplicationController
  include Authenticated

  layout 'survey'

  def show
    respond_to do |format|
      format.html { render :show, locals: { grid: } }
      format.csv  { render_file :show, export_name(survey), locals: { grid: } }
      format.xlsx { render_file :show, export_name(survey), locals: { grid: } }
    end
  end

  def rows
    render partial: 'data_grid/rows', locals: { grid: }
  end

  def table
    render partial: 'data_grid/table', locals: { grid: }
  end

  private

  def render_file(view, filename, **options)
    render view, **options
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
  end

  def export_name(survey)
    "#{survey.slug}-#{Dragnet::Utils.slug(Time.zone.now)}.#{params[:format]}"
  end

  def grid
    Dragnet::DataGridPresenter.new(Dragnet::DataGrid.find_or_create!(survey, user: current_user), data_grid_params)
  end

  def survey
    @survey ||= Dragnet::Survey.whole.find(params[:survey_id])
  end

  def data_grid_params
    params.permit(:page, :items, :sort_by, :sort_direction, :created_at, :user_id, filter_by: {})
  end
end
