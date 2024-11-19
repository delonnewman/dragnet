module Dragnet
  class Email < Type::Text
    ignore :calculate_stats_table, :calculate_occurrence_table

    def get_value(...)
      GetValueEmail.new(...)
    end
  end
end
