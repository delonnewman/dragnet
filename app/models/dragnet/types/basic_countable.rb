module Dragnet
  module Types
    class BasicCountable < Basic
      perform :calculate_stats_table, class_name: 'Dragnet::StatsReport::CalculateStatsTable'
      perform :calculate_occurrence_table, class_name: 'Dragnet::StatsReport::CalculateOccurenceTable'
    end
  end
end
