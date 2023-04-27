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

      def to_s
        content = children.map(&:to_s).join('')
        if attributes?
          attr_list = attributes.map { |name, a| "#{name}=#{a.value.to_s.inspect}" }.join(' ')
          "<#{name} #{attr_list}>#{content}</#{name}>"
        else
          "<#{name}>#{content}</#{name}>"
        end
      end
    end
  end
end
