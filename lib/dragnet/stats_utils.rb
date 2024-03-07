# frozen_string_literal: true

module Dragnet
  module StatsUtils
    module_function

    # @param [Range<Date>] range
    # @return [Hash{Date => Integer}]
    def time_series(range)
      range.index_with do
        if rand(4).zero?
          rand(400)
        else
          rand(20)
        end
      end
    end

    # Normalize values to values between 0 and 1.
    #
    # @param [Array<Numeric>]
    #
    # @return [Array<Numeric>]
    def normalize_values(values)
      min = values.min.to_f
      max = values.max.to_f

      values.map do |value|
        (value - min) / (max - min)
      end
    end
  end
end
