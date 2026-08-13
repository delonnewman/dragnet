module Dragnet
  module Types
    class LongText < Text
      perform :do_before_saving_answer, class_name: 'Dragnet::Answer::DoBeforeSaving'

      def countable?
        question.settings.countable?
      end
      alias calculate_sentiment? countable?
    end
  end
end
