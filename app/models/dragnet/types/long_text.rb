module Dragnet
  module Types
    class LongText < Text
      def calculate_sentiment?(question)
        question.settings.countable?
      end
    end
  end
end
