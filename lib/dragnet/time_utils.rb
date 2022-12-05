module Dragnet
  module TimeUtils
    module_function

    # @param value [Integer, #hour]
    #
    # @return [String]
    def fmt_hour(value)
      hour = value.respond_to?(:hour) ? value.hour : value
      ampm = hour >= 12 ? 'PM' : 'AM'
      hr   = hour > 12 ? hour % 12 : hour
      hr   = hr.zero? ? 12 : hr

      "#{hr} #{ampm}"
    end
  end
end
