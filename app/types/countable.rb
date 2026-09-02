module Dragnet
  module Types
    class Countable < Basic
      def calculate_stats_table(...) =
        StatsReport::CalculateStatsTable.new(question, ...)
      def calculate_occurrence_table(...) =
        StatsReport::CalculateOccurrenceTable.new(question, ...)
    end
  end
end
