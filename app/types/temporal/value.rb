module Dragnet::Types
  class Temporal::Value < Dragnet::Value
    delegate :to_date, :to_time, :to_datetime, to: :@value, allow_nil: true

    def initialize(value)
      @value = value
    end

    def text_value
      @value&.to_s
    end

    def number_value
      @value&.to_i
    end
  end
end
