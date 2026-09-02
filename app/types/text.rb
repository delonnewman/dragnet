module Dragnet
  module Types
    class Text < Countable
      def do_before_saving_answer(...) = DoNothing.new

      def build_value(answer)
        Value.new(answer.short_text_value)
      end

      def assign_value(answer, value)
        answer.short_text_value = value.to_s
      end

      def countable?
        false
      end
    end
  end
end
