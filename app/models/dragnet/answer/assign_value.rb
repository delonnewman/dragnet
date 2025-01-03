module Dragnet
  class Answer::AssignValue < GenericFunction
    attribute :answer
    attribute :value

    def boolean
      answer.boolean_value = value
    end

    def choice
      answer.question_option_id = value
    end

    def decimal
      answer.float_value = value
    end

    def integer
      answer.integer_value = value
    end

    def text
      if answer.question.settings.long_answer?
        answer.long_text_value = value
      else
        answer.short_text_value = value
      end
    end

    def time
      answer.time_value = value
    end

    def date
      answer.date_value = value
    end

    def date_and_time
      answer.time_value = value.to_time
      answer.date_value = value.to_date
    end
  end
end
