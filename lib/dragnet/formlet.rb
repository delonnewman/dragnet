# frozen_string_literal: true

module Dragnet
  class Formlet
    attr_reader :id, :name

    def self.tag
      name.demodulize.underscore.dasherize.to_sym
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

    def initialize(**attributes)
      self.class.attributes.each do |attribute|
        raise ArgumentError, "#{attribute} is required" unless attributes.key?(attribute)

        instance_variable_set(:"@#{attribute}", attributes[attribute])
      end

      @id = Utils.tagged_uuid(self.class.tag)
      @name = attributes.fetch(:name, @id)
    end

    def render_in(_context)
      html
    end

    def to_s
      html
    end

    def yields(params)
      params[name]
    end

    def *(other)
      ComposedFormlets.with(self, other)
    end
  end
end
