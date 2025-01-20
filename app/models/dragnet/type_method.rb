# frozen_string_literal: true

module Dragnet
  class TypeMethod
    def self.message_name
      name.demodulize.underscore.to_sym
    end

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

    def initialize(question, **attributes)
      @question = question
      self.class.attributes.each do |attribute|
        raise ArgumentError, "#{attribute} is required" unless attributes.key?(attribute)

        instance_variable_set(:"@#{attribute}", attributes[attribute])
      end
    end

    def send_type(type)
      type.tags.each do |tag|
        return public_send(tag) if respond_to?(tag)
      end

      raise NoMethodError, "undefined method `#{self.class.message_name}` for #{type.class} tried with #{type.tags.to_sentence}"
    end

    private

    attr_reader :question

    delegate :type, to: :question
  end
end
