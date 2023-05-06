# frozen_string_literal: true

module Dragnet
  module DOM
    class Context
      def let(name, &block)
        define_method(name, &block)
      end
    end
  end
end
