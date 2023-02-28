# frozen_string_literal: true

module Dragnet
  module QuestionTypes
    class TextType < Base
      def answer_value_field
        :text_value
      end
      #
      # def filter_value(value)
      #   "%#{value}%"
      # end
      #
      # def filter_operator
      #   :like
      # end
    end
  end
end
