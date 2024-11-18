class Dragnet
  class Action::AssignValue < Action
    private attr_reader :answer, :value

    def initialize(answer:, value:)
      @answer = answer
      @value = value
    end

    def boolean(type)
      answer.boolean_value = value
    end

    def choice(type)
      answer.question_option_id = value
    end

    def number(type)
      if answer.question.settings.decimal?
        answer.float_value = value
      else
        answer.integer_value = value
      end
    end

    def text(type)
      if answer.question.settings.long_answer?
        answer.long_text_value = value
      else
        answer.short_text_value = value
      end
    end

    def time(type)
      answer.time_value = value if answer.question.settings.include_time?
      answer.date_value = value if answer.question.settings.include_date?
    end
  end
end
