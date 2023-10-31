# frozen_string_literal: true

module Dragnet
  module Perspectives
    # @abstract
    # A polymorphic perspective for answer evaluation, subclasses dispatch on the following methods.
    class AnswerEvaluation < Base
      # Assign the given value to the appropriate attribute
      # @param [Answer] answer
      # @param [Object] value
      def assign_value!(answer, value)
        raise Answer::EvaluationError, "can't evaluate #{value.inspect}:#{value.class} for #{answer.question_type}"
      end

      # @param [Answer] answer
      # @return [Object] the evaluated answer
      def value(answer)
        raise Answer::EvaluationError, "can't get value from question type: #{answer.question_type}"
      end

      # Return a numeric value that is appropriate for the type. Will be used in calculations and dashboards
      # @param [Answer] answer
      # @return [Numeric]
      def number_value(answer)
        raise Answer::EvaluationError, "can't convert #{answer.question_type} to number"
      end

      # @!method sort_value
      #   Return a value that is appropriate for the type for sorting in the data grid and reports
      #   @param [Answer] answer
      #   @return [Object]
      alias sort_value number_value
    end
  end
end