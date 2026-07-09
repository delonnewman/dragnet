class DataGrid::ToolsController < DataGridController
  def show
    render partial: 'data_grid/tools', locals: { grid: }
  end
end
