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

  def calculate_sentiment?(question)
    question.settings.long_answer? && question.settings.countable?
  end
end
