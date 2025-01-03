module Dragnet
  module Types
    class Basic < Type
      perform :assign_value, class_name: 'Dragnet::Answer::AssignValue'
      perform :get_value, class_name: 'Dragnet::Answer::GetValue'
      perform :get_number_value, class_name: 'Dragnet::Answer::GetNumberValue'
      perform :filter_data_grid, class_name: 'Dragnet::DataGrid::Filter'
      perform :sort_data_grid, class_name: 'Dragnet::DataGrid::Sort'

      perform :data_grid_display, class_name: 'Dragnet::DataGridDisplay'
      perform :filter_input_display, class_name: 'Dragnet::FilterInputDisplay'
    end
  end
end
