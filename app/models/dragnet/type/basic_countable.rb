module Dragnet
  class Type::BasicCountable < Type::Basic
    perform :calculate_stats_table, class_name: 'Dragnet::Action::CalculateStatsTable'
    perform :calculate_occurrence_table, class_name: 'Dragnet::Action::CalculateOccurenceTable'
  end
end
