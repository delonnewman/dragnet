# frozen_string_literal: true

module Dragnet
  module Perspectives
    # @abstract
    # An abstraction for creating class systems for polymorphic evaluation of
    # various values based on question type.
    #
    # This approach allows question types to be a principle means of extension
    # for the system.  Since defining new subclasses of the perspective allows
    # the perspectives to work for any future type.
    #
    # See subclasses for examples of usage
    class Base
      class << self
        # @param [QuestionType, Symbol] type
        #
        # @return [Base]
        def get(type)
          question_type = type.is_a?(Symbol) ? type : type.ident
          class_name    = question_type.name.classify
          klass         = const_defined?(class_name, false) ? const_get(class_name) : self

          klass.new(QuestionType.get(question_type))
        end
      end

      # @return [QuestionType]
      attr_reader :question_type

      # @param [QuestionType] question_type
      def initialize(question_type)
        @question_type = question_type
      end
    end
  end
end
