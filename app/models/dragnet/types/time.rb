module Dragnet
  module Types
    class Time < Temporal
      def self.decode(value)
        super(value).to_time
      end
    end
  end
end
