# frozen_string_literal: true

class DataGridController < ApplicationController
  include Authenticated

  layout 'survey'

  def show
    respond_to do |format|
      format.html { render :show, locals: { grid: } }
      format.csv  { render_file :show, locals: { grid: } }
      format.xlsx { render_file :show, locals: { grid: } }
      format.transit { render transit: grid.to_h }
      format.json { render :show, locals: { grid: } }
    end
  end

  def rows
    render partial: 'data_grid/rows', locals: { grid: }
  end

  def table
    render partial: 'data_grid/table', locals: { grid: }
  end

  private

  def render_file(view, **options)
    render view, **options
    filename = export_name(survey)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
  end

  def export_name(survey)
    "#{survey.slug}-#{Dragnet::Utils.slug(Time.zone.now)}.#{params[:format]}"
  end

  def grid
    Dragnet::DataGrid.find_or_create!(survey, user: current_user).present(with: data_grid_params)
  end

  def survey
    @survey ||= Dragnet::Survey.whole.find(params[:survey_id])
  end

  def data_grid_params
    params.permit(:page, :items, :sort_by, :sort_direction, :created_at, :user_id, :survey_id, filter_by: {})
  end
end
