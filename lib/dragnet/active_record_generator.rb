module Dragnet
  class ActiveRecordGenerator
    include Dragnet
    include Dragnet::Generators

    class << self
      def parameterized?
        true
      end

      def [](*args)
        new(active_record_class, *args)
      end

      def generate(*args)
        obj = new(active_record_class)
        return obj.generate if args.empty?

        obj.generate(*args)
      end

      def generate!(*args)
        generate(*args).tap(&:save!)
      end

      def active_record_class_name
        name.gsub(/Generator$/, '')
      end

      def active_record_class
        active_record_class_name.safe_constantize
      end
    end

    attr_reader :active_record_class, :attributes

    def initialize(active_record_class, attributes = EMPTY_HASH)
      @attributes = attributes.generate
      @active_record_class = active_record_class
    end

    def [](attributes)
      @attributes = attributes.generate

      self
    end

    # TODO: add logic for generating instances through reflection
    def generate(other_attributes = EMPTY_HASH)
      return call                            if respond_to?(:call) && other_attributes.empty?
      return call(other_attributes.generate) if respond_to?(:call)

      active_record_class.new(attributes.merge(other_attributes.generate))
    end

    def generate!(other_attributes = EMPTY_HASH)
      generate(other_attributes).tap(&:save!)
    end
  end
end
