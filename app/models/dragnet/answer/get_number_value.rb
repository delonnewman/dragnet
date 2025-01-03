module Dragnet
  class Answer::GetNumberValue < GetValue
    attribute :answer

    def boolean
      raise Answer::EvaluationError, "can't convert #{type} to number"
    end

    def choice
      answer.question_option&.weight
    end

    def long_text
      raise Answer::EvaluationError, "can't convert #{type} to number" unless type.calculate_sentiment?(answer.question)

      answer.float_value
    end

    def temporal
      super&.to_i
    end
  end
end
