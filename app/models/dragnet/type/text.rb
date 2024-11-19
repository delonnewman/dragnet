module Dragnet
  class Type::Text < Type
    perform \
      :assign_value,
      :get_value,
      :get_number_value,
      :do_before_saving_answer,
      :filter_data_grid,
      :sort_data_grid,
      :calculate_stats_table,
      :calculate_occurrence_table
  end
end
