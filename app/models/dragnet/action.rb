module Dragnet
  class Action
    def self.attributes
      @attributes ||= []
    end

    def self.attribute(name)
      attributes << name
      private attr_reader name
    end

    def initialize(attributes)
      self.class.attributes.each do |attribute|
        raise ArgumentError, "#{attribute} is required" unless attributes.key?(attribute)

        instance_variable_set(:"@#{attribute}", attributes[attribute])
      end
    end

    def send_type(question_type)
      public_send(question_type.ident, question_type)
    end
  end
end
