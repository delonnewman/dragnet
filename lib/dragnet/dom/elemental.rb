# frozen_string_literal: true

module Dragnet
  module DOM
    module Elemental
      include Memoizable

      # Return an array of the children of this element that are elements
      # @return [Array<Element>]
      def child_elements
        children.grep(Element)
      end
      memoize :child_elements
    end
  end
end
