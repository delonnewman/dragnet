module Dragnet::Types
  class Boolean::Value < Dragnet::Value
    def initialize(value)
      @value = value
    end

    def text_value
      @value ? 'Yes' : 'No'
    end

    def !
      !@value
    end
  end
end
