# frozen_string_literal: true

module Dragnet
  module DOM
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Text
    class Text < Node
      include CharacterData

      def initialize(content:, **args)
        super(freeze: false, **args)
        @data = content
        freeze
      end

      alias content data

      def name
        '#text'
      end

      def to_s
        CGI.escapeHTML(content)
      end
    end
  end
end
