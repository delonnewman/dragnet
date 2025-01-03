# frozen_string_literal: true

module Dragnet
  class GenericFunction
    def self.attributes
      return @attributes if defined?(@attributes)

      @attributes =
        if superclass.respond_to?(:attributes)
          superclass.attributes.dup
        else
          []
        end
    end

    def self.attribute(name)
      attributes << name
      private attr_reader name
    end

    def initialize(question_type, **attributes)
      @question_type = question_type
      self.class.attributes.each do |attribute|
        raise ArgumentError, "#{attribute} is required" unless attributes.key?(attribute)

        instance_variable_set(:"@#{attribute}", attributes[attribute])
      end
    end

    def send_type(type)
      type.tags.each do |tag|
        return public_send(tag) if respond_to?(tag)
      end

      raise NoMethodError, "undefined method `#{type.tags.to_sentence}` for #{self}:#{self.class}"
    end

    private

    attr_reader :question_type

    delegate :type, to: :question_type
  end
end
