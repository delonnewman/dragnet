module Dragnet
  module Types
    module Countable
      S = StatsReport
      def collect_stats(...)    = S::CollectStats.new(question, ...)
      def create_histogram(...) = S::CreateHistogram.new(question, ...)
    end
  end
end
