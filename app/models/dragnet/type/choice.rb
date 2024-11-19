module Dragnet
  class Type::Choice < Type
    ignore :do_before_saving_answer

    perform \
      :assign_value,
      :get_value,
      :get_number_value,
      :filter_data_grid,
      :sort_data_grid,
      :calculate_stats_table,
      :calculate_occurrence_table
  end
end
