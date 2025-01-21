module Dragnet
  module Types
    class DateAndTime < Temporal
      def self.decode(value)
        super(value).to_time
      end
    end
  end
end
