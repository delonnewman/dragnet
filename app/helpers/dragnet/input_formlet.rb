module Dragnet
  class InputFormlet < Formlet
    def self.value_type(type = nil)
      @value_type = type if type
      @value_type
    end

    delegate :value_type, to: 'self.class'

    def initialize(**attributes)
      super(**attributes)
      @value = attributes.fetch(:value, nil)
    end

    def value
      return @value unless @value && value_type

      value_type.encode(@value)
    end

    def yields(params)
      return super unless value_type

      value_type.decode(params[name])
    end
  end
end
