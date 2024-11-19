module Dragnet
  class Action::GetValue < Action
    attribute :answer

    def boolean
      answer.boolean_value
    end

    def choice
      answer.question_option&.text
    end

    def number
      if answer.question.settings.decimal?
        answer.float_value
      else
        answer.integer_value
      end
    end

    def text
      return answer.long_text_value if answer.question.settings.long_answer?

      answer.short_text_value
    end

    def time
      question = answer.question
      date = answer.date_value
      time = answer.time_value

      if date && time && question.settings.include_date_and_time?
        return DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.utc_offset)
      end

      return date if date && question.settings.include_date?

      time
    end
  end
end
