module Dragnet::Types
  class Number::Value < Dragnet::Value
    def initialize(value)
      @value = value
      freeze
    end

    def text_value
      @value.to_s
    end

    def number_value
      @value
    end
  end
end
