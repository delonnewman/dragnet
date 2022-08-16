module Dragnet
  class Advice
    include Dragnet

    class << self
      def advice?
        true
      end

      def advised_object_method_name(advised_class)
        return unless advised_class

        advised_class.name.split('::').last.underscore.to_sym
      end

      def advises(*advised_classes, as: advised_object_method_name(advised_classes.first))
        self.advised_classes = advised_classes
        self.advised_object_alias = as

        define_method(as) { advised_object } if as
      end

      attr_reader :advised_classes, :advised_object_alias

      private

      attr_writer :advised_classes, :advised_object_alias
    end

    attr_reader :advised_object

    def initialize(advised_object)
      @advised_object = advised_object
    end
  end
end
