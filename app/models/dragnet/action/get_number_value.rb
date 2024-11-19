module Dragnet
  class Action::GetNumberValue < Action::GetValue
    attribute :answer

    def boolean(type)
      raise Answer::EvaluationError, "can't convert #{type} to number"
    end

    def choice(type)
      answer.question_option&.weight
    end

    def text(type)
      raise Answer::EvaluationError, "can't convert #{type} to number"
    end

    def time(type)
      super&.to_i
    end
  end
end
