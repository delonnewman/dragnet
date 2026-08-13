module Dragnet
  module Types
    class Date < Temporal
      def self.decode(value)
        super(value).to_date
      end
    end
  end
end
