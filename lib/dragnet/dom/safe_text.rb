# frozen_string_literal: true

module Dragnet
  module DOM
    class SafeText < Text
      def name
        '#safe-text'
      end
    end
  end
end
