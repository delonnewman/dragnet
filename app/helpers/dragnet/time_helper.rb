# frozen_string_literal: true

module Dragnet
  module TimeHelper
    def format_date(date, alt = '-')
      return alt unless date

      date.strftime('%-m/%d/%Y')
    end

    def format_time(time, alt = '-')
      return alt unless time

      time.strftime('%l:%M %p')
    end

    def format_datetime(time, alt = '-')
      return alt unless time

      format_date(time) + ' ' + format_time(time)
    end
  end
end