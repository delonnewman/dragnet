# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLDOMBuilder
      include HTMLVoidTags
      include HTMLStandardTags

      attr_reader :context

      def initialize(context)
        @context = context
      end

      def attributes
        Hash.new do |_, key|
          "<%= attributes[#{key.inspect}] %>"
        end
      end

      def text(content = nil, &block)
        if content
          Text.new(content: content)
        else
          Text.new(content: block.call)
        end
      end

      def space(count = nil)
        count ||= 1

        Text.new(content: " " * count)
      end
    end
  end
end
