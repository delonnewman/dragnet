module Dragnet
  class Answer::GetValue < GenericFunction
    attribute :answer

    def boolean
      answer.boolean_value
    end

    def choice
      answer.question_option&.text
    end

    def decimal
      answer.float_value
    end

    def integer
      answer.integer_value
    end

    def text
      return answer.long_text_value if answer.question.settings.long_answer?

      answer.short_text_value
    end

    def time
      answer.time_value
    end

    def date
      answer.date_value
    end

    def date_and_time
      DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.utc_offset)
    end
  end
end
