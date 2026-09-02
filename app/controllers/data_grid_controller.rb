# frozen_string_literal: true

class DataGridController < ApplicationController
  include Authenticated

  layout 'survey'

  helper_method :data_grid_params

  def show
    respond_to do |format|
      format.html { render :show, locals: { grid: } }
      format.csv  { render_file :show, locals: { grid: } }
      format.xlsx { render_file :show, locals: { grid: } }
      format.json { render :show, locals: { grid: } }
    end
  end

  def table
    render partial: 'data_grid/table', locals: { grid: }
  end

  private

  def render_file(view, **)
    render view, **
    filename = export_name(survey)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
  end

  def export_name(survey)
    "#{survey.slug}-#{Dragnet::Utils.slug(Time.zone.now)}.#{params[:format]}"
  end

  def grid
    survey_id = params[:survey_id]
    author_id = current_user.id

    current_user.data_grids.includes(
      :author,
      questions: %i[question_options],
      replies: { answers: %i[question] }
    ).find_or_create_by!(survey_id:, author_id:).present(with: params)
  end

  # TODO: may not be using this
  def survey
    @survey ||= Dragnet::Survey.whole.find(params[:survey_id])
  end

  # TODO: we may not need this
  def data_grid_params
    params.permit(
      :format,
      :page,
      :items,
      :sort_by,
      :sort_direction,
      :created_at,
      :user_id,
      :survey_id,
      filter_by: {}
    )
  end
end
