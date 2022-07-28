module Dragnet
  class Advice
    include Dragnet

    class << self
      def aspect?
        true
      end

      def composing_object_method_name(composing_class)
        return unless composing_class

        composing_class.name.split('::').last.underscore.to_sym
      end

      def advises(*composing_classes, alias_as: composing_object_method_name(composing_classes.first))
        self.composing_classes = composing_classes

        define_method(alias_as) { composing_object } if alias_as
      end

      attr_reader :composing_classes

      private

      attr_writer :composing_classes
    end

    attr_reader :composing_object

    def initialize(composing_object)
      @composing_object = composing_object
    end
  end
end
