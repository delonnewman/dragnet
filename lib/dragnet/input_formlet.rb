module Dragnet
  class InputFormlet < Formlet
    def self.value_type(type = nil)
      @value_type = type if type
      @value_type
    end

    def self.input_type(type = nil)
      @input_type = type if type
      @input_type
    end

    attribute :label
    delegate :value_type, :input_type, to: 'self.class'

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

    def html
      <<~HTML.squish!
        <input
          type="#{input_type}"
          class="form-control"
          id="#{id}"
          name="#{name}
          value="#{value}"
          placeholder="#{label}"
          aria-label="#{label}">
      HTML
    end
  end
end
