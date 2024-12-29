# frozen_string_literal: true

module Dragnet
  class Action
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

    def send_type(question_type)
      public_send(question_type.ident)
    end

    private

    attr_reader :question_type

    delegate :type, to: :question_type
  end
end
