module Dragnet
  class Aspect
    class << self
      def aspect?
        true
      end

      def composing_object_method_name(composed_class)
        composed_class.name.split('::').last.underscore.to_sym
      end

      def aspect_of(composed_class, alias_as: composing_object_method_name(composed_class))
        self.composed_class = composed_class

        define_method(alias_as) { composed_object }
      end

      attr_reader :composed_class

      private

      attr_writer :composed_class
    end

    attr_reader :composed_object

    def initialize(composed_object)
      @composed_object = composed_object
    end
  end
end