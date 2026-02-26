module Dragnet
  module Types
    class Basic < Type
      perform :assign_value, class_name: 'Dragnet::Answer::AssignValue'
      perform :get_value, class_name: 'Dragnet::Answer::GetValue'
      perform :get_number_value, class_name: 'Dragnet::Answer::GetNumberValue'

      perform :filter_data_grid, class_name: 'Dragnet::DataGrid::Filter'
      perform :sort_data_grid, class_name: 'Dragnet::DataGrid::Sort'
      perform :render_answers_text, class_name: 'Dragnet::DataGrid::RenderAnswersText'
      perform :get_text_alignment, class_name: 'Dragnet::DataGrid::GetTextAlignment'
    end
  end
end
