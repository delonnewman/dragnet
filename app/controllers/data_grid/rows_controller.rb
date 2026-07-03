class DataGrid::RowsController < DataGridController
  def index
    render partial: 'data_grid/rows', locals: { grid: }
  end

  def create
    record = survey.replies.create!(user: current_user)
    render partial: 'data_grid/edit_row', locals: { record:, grid: }
  end

  # TODO: we'll probably just want to retract here
  def destroy
    survey.replies.find(params[:id]).delete

    response.headers["HX-Trigger"] = 'rows-updated'
    render partial: 'data_grid/rows', locals: { grid: }
  end
end
