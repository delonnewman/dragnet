# frozen_string_literal: true

# A polymorphic perspective for answer evaluation, subclasses dispatch on the following methods.
#
# @!method assign_value!
#   Assign the given value to the appropriate attribute
#   @param [Answer] answer
#   @param [Object] value
#
# @!method value
#   @param [Answer] answer
#   @return [Object] the evaluated answer
#
# @!method number_value
#   Return a numeric value that is appropriate for the type. Will be used in calculations and dashboards
#   @param [Answer] answer
#   @return [Numeric]
#
# @!method sort_value
#   Return a value that is appropriate for the type for sorting in the data grid and reports
#   @param [Answer] answer
#   @return [Object]
class AnswerEvaluationPerspective < Perspective
  default do
    def assign_value!(_answer, value)
      raise Answer::EvaluationError, "can't evaluate #{value.inspect}:#{value.class}"
    end

    def value(answer)
      raise Answer::EvaluationError, "can't get value from question type: #{answer.question_type}"
    end

    def number_value(answer)
      raise Answer::EvaluationError, "can't convert #{answer.question_type} to number"
    end

    alias sort_value number_value
  end

  for_type :text do
    def assign_value!(answer, value)
      if answer.question.long_answer?
        answer.long_text_value = value
      else
        answer.short_text_value = value
      end
    end

    def value(answer)
      return answer.long_text_value if answer.question.long_answer?

      answer.short_text_value
    end

    alias sort_value value
  end

  for_type :choice do
    def assign_value!(answer, value)
      answer.question_option = value
    end

    def value(answer)
      answer.question_option&.text
    end

    def number_value(answer)
      answer.question_option&.weight
    end
  end

  for_type :number do
    def assign_value!(answer, value)
      answer.float_value = value
    end

    def value(answer)
      answer.float_value
    end

    alias number_value value
  end

  for_type :time do
    def assign_value!(answer, value)
      answer.time_value = value
    end

    def value(answer)
      t = answer.time_value
      return t if answer.question.include_time?

      t.to_date
    end

    def number_value(answer)
      answer.time_value.to_i
    end
  end
end
