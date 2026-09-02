module Dragnet
  module Types
    class Choice < Countable
      def do_before_saving_answer(...) = DoNothing.new

      def build_value_from_answer(answer)
        option = answer.question_option
        Value.new(text: option.text, weight: option.weight)
      end

      def assign_value(answer, value)
        case value
        when Dragnet::QuestionOption
          answer.question_option = value
        else
          answer.question_option_id = value
        end
      end
    end
  end
end
