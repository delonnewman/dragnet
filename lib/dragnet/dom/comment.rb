# frozen_string_literal: true

module Dragnet
  module DOM
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Comment
    class Comment < Node
      include CharacterData

      def name
        '#comment'
      end
    end
  end
end
