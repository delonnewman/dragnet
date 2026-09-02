module Dragnet::Types
  class Text::Value < Dragnet::Value
    def initialize(string, number = nil)
      @string = string
      @number = number
      freeze
    end

    def text_value
      @string
    end

    def number_value
      @number or raise "No number value for #{inspect}"
    end
  end
end
