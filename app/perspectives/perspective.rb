# @abstract
# An abstraction for creating class systems for polymorphic evaluation of
# various value based on question type.
#
# It provides a simple DSL that creates subclasses of the types where the
# polymorphic interface can be defined.  The DSL is entirely optional, but
# helps to abstract away and establish this pattern throughout the system.
#
#
# This approach allows question types to be a principle means of extension
# for the system.  Since defining new subclasses of the perspective allows
# the perspectives to work for any future type.
#
# See subclasses for examples of usage
class Perspective
  class << self
    # @param [QuestionType, Symbol] type
    #
    # @return [Symbol]
    def for_type(type, &block)
      question_type = type.is_a?(Symbol) ? type : type.ident
      class_name    = question_type.name.classify

      klass =
        if const_defined?(class_name, false)
          const_get(class_name)
        else
          Class.new(self).tap do |klass|
            const_set(class_name, klass)
          end
        end

      klass.class_eval(&block)
      perspectives << question_type
      question_type
    end

    def default(&block)
      for_type(:default, &block)
    end

    # @return [Array<Symbol>]
    def perspectives
      @perspectives ||= []
    end

    # @param [QuestionType, Symbol] type
    #
    # @return [Perspective]
    def get(type)
      question_type = type.is_a?(Symbol) ? type : type.ident
      class_name    = question_type.name.classify
      klass         = const_defined?(class_name, false) ? const_get(class_name) : const_get("#{self.name}::Default")

      klass.new(QuestionType.get(question_type))
    end
  end

  class Default < self; end

  # @return [QuestionType]
  attr_reader :question_type

  # @param [QuestionType] question_type
  def initialize(question_type)
    @question_type = question_type
  end
end
