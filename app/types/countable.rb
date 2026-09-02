module Dragnet
  module Types
    class Countable < Basic
      # TODO: rename to calculate_stats
      def calculate_stats_table(...) =
        StatsReport::CalculateStatsTable.new(question, ...)
      # TODO: rename to calculate_tallies
      def calculate_occurrence_table(...) =
        StatsReport::CalculateOccurrenceTable.new(question, ...)
    end
  end
end
