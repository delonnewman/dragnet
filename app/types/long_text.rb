module Dragnet
  module Types
    class LongText < Text
      include Countable

      def do_before_saving_answer(...) = Answer::DoBeforeSaving.new(question, ...)

      def build_value_from_answer(answer)
        Value.new(answer.long_text_value, answer.float_value)
      end

      def assign_value(answer, value)
        answer.long_text_value = value.to_s
      end

      def countable?
        question.settings.countable?
      end
      alias calculate_sentiment? countable?
    end
  end
end
