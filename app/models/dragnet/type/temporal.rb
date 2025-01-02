module Dragnet
  class Type::Temporal < Type
    ignore :do_before_saving_answer

    perform \
      :assign_value,
      :get_value,
      :get_number_value,
      :filter_data_grid,
      :sort_data_grid
  end
end
