module Dragnet
  module Types
    class Basic < Type
      perform :assign_value, class_name: 'Dragnet::AssignValue'
      perform :get_value, class_name: 'Dragnet::GetValue'
      perform :get_number_value, class_name: 'Dragnet::GetNumberValue'
      perform :filter_data_grid, class_name: 'Dragnet::FilterDataGrid'
      perform :sort_data_grid, class_name: 'Dragnet::SortDataGrid'

      perform :data_grid_display, class_name: 'Dragent::DataGridDisplay'
      perform :filter_input_display, class_name: 'Dragent::FilterInputDisplay'
    end
  end
end
