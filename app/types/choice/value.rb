module Dragnet::Types
  class Choice::Value < Dragnet::Value
    attr_reader :text, :weight

    # @param text [String]
    # @param weight [Numeric]
    def initialize(text:, weight:)
      @text   = text
      @weight = weight
      freeze
    end

    def text_value
      @text
    end

    def number_value
      @weight
    end

    def to_h
      { text: @text, weight: @weight }
    end

    def to_a
      [@text, @weight]
    end
  end
end
