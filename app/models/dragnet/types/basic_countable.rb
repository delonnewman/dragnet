module Dragnet
  module Types
    class BasicCountable < Basic
      perform :calculate_stats_table, class_name: 'Dragnet::CalculateStatsTable'
      perform :calculate_occurrence_table, class_name: 'Dragnet::CalculateOccurenceTable'
    end
  end
end
