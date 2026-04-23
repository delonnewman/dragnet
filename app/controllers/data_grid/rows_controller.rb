class DataGrid::RowsController < DataGridController
  def index
    render partial: 'data_grid/rows', locals: { grid: }
  end
end
