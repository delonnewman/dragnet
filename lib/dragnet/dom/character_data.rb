# frozen_string_literal: true

module Dragnet
  module DOM
    # Common methods for character oriented nodes
    # @see https://developer.mozilla.org/en-US/docs/Web/API/CharacterData
    module CharacterData
      # @return [String]
      attr_accessor :data

      delegate :length, :size, :count, to: :data

      def next_element_sibling
        index = siblings.index(self)
        return unless index

        siblings[index, siblings.length - index].find do |node|
          node.is_a?(Element)
        end
      end

      def previous_element_sibling
        index = siblings.index(self)
        return unless index

        siblings[0, index].reverse!.find do |node|
          node.is_a?(Element)
        end
      end
    end
  end
end
