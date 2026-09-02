module Dragnet
  module Types
    class LongText < Text
      def do_before_saving_answer(...) = Answer::DoBeforeSaving.new(question, ...)

      def build_value(answer)
        Value.new(answer.long_text_value, answer.float_value)
      end

      def assign_value(answer, value)
        answer.long_text_value = encode(value)
      end

      def countable?
        question.settings.countable?
      end
      alias calculate_sentiment? countable?
    end
  end
end
