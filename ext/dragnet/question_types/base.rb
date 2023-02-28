# frozen_string_literal: true

module Dragnet
  module QuestionTypes
    class Base
      attr_reader :question_type_record

      def initialize(question_type_record)
        raise "Cannot instantiate base class" if self.class == Base
        @question_type_record = question_type_record
      end

      def answer_value_field
        raise NotImplementedError
      end

      def filter_value(value)
        value
      end

      def filter_operator
        :'='
      end
    end
  end
end
