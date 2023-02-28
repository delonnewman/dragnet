# frozen_string_literal: true

module Dragnet
  module QuestionTypes
    class NumberType < Base
      def answer_value_field
        :float_value
      end
    end
  end
end
