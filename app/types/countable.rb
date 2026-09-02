module Dragnet
  module Types
    module Countable
      def stats_table(...)   = StatsReport::CollectStats.new(question, ...)
      def tallies_table(...) = StatsReport::CreateHistogram.new(question, ...)
    end
  end
end
