# frozen_string_literal: true

module Dragnet
  module QuestionTypes
    class ChoiceType < Base
      def answer_value_field
        :question_option_id
      end
    end
  end
end
