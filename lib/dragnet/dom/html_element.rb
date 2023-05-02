# frozen_string_literal: true

module Dragnet
  module DOM
    # @see https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement
    class HTMLElement < Element
      # TODO: add style_map

      def styles
        attribute('styles')
      end

      def title
        attribute('title')
      end

      def hidden?
        !!hidden
      end

      def hidden
        attribute('hidden').presence
      end
    end
  end
end
