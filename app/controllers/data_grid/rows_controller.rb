class DataGrid::RowsController < DataGridController
  def index
    render partial: 'data_grid/rows', locals: { grid: }
  end

  def create
    record = survey.replies.create!(user: current_user)
    render partial: 'data_grid/edit_row', locals: { record:, grid: }
  end
end
