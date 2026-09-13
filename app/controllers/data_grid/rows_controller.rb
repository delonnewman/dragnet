# frozen_string_literal: true

class DataGrid::RowsController < DataGridController
  def index
    render partial: 'data_grid/rows', locals: { grid: }
  end

  def edit
    record = survey.replies.find(params[:id])
    render partial: 'data_grid/edit_row', locals: { record:, grid: }
  end

  def create
    record = survey.replies.create!(user: current_user)
    render partial: 'data_grid/edit_row', locals: { record:, grid: }
  end

  def update
    record = survey.replies.find(params[:id])
    record.update!(reply_params)
    record.answers_cache.reset!

    render partial: 'data_grid/rows', locals: { grid: }
  end

  # TODO: we'll probably just want to retract here
  def destroy
    survey.replies.find(params[:id]).delete

    response.headers['HX-Trigger'] = 'rows-updated'
    render partial: 'data_grid/rows', locals: { grid: }
  end

  private

  def reply_params
    params.require(:reply).permit(survey.submission_parameters.reply_attributes)
  end
end
