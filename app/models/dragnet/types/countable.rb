module Dragnet
  module Types
    class Countable < Basic
      perform :calculate_stats_table, class_name: 'Dragnet::StatsReport::CalculateStatsTable'
      perform :calculate_occurrence_table, class_name: 'Dragnet::StatsReport::CalculateOccurrenceTable'
    end
  end
end
