module Dragnet
  module Types
    class Choice < Countable
      ignore :do_before_saving_answer

      def build_value(answer)
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
