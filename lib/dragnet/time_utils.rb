module Dragnet
  module TimeUtils
    module_function

    def fmt_hour(hour)
      ampm = hour >= 12 ? 'PM' : 'AM'
      hr   = hour > 12 ? hour % 12 : hour
      hr   = hr.zero? ? 12 : hr

      "#{hr} #{ampm}"
    end
  end
end
