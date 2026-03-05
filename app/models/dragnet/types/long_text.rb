module Dragnet
  module Types
    class LongText < Text
      def countable?
        question.settings.countable?
      end
      alias calculate_sentiment? countable?
    end
  end
end
