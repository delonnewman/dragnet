module Dragnet
  class Type::Basic < Type
    perform :assign_value, class_name: 'Dragnet::Action::AssignValue'
    perform :get_value, class_name: 'Dragnet::Action::GetValue'
    perform :get_number_value, class_name: 'Dragnet::Action::GetNumberValue'
    perform :filter_data_grid, class_name: 'Dragnet::Action::FilterDataGrid'
    perform :sort_data_grid, class_name: 'Dragnet::Action::SortDataGrid'
  end
end
