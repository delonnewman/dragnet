require 'securerandom'

module Dragnet
  class Formlet
    attr_reader :id, :name

    delegate :tag, to: :@view_context

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

      @id = SecureRandom.uuid
      @name = attributes.fetch(:name) do
        "#{self.class.name.split('::').last.downcase}_#{ShortUUID.shorten(@id)}"
      end
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

    def compose(other)
      ComposedFormlet.new(self, other)
    end
  end
end
