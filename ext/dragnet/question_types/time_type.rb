# frozen_string_literal: true

module Dragnet
  module QuestionTypes
    class TimeType < Base
      def answer_value_field
        :integer_value
      end
    end
  end
end
