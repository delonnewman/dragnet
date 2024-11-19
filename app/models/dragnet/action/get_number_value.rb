module Dragnet
  class Action::GetNumberValue < Action::GetValue
    attribute :answer

    def boolean
      raise Answer::EvaluationError, "can't convert #{type} to number"
    end

    def choice
      answer.question_option&.weight
    end

    def text
      unless type.calculate_sentiment?(answer.question)
        raise Answer::EvaluationError, "can't convert #{type} to number"
      end

      answer.float_value
    end

    def time
      super&.to_i
    end
    alias date time
    alias date_and_time time
  end
end
