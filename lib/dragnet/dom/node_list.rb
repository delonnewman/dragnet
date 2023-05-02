# frozen_string_literal: true

module Dragnet
  module DOM
    class NodeList < Node
      attr_reader :nodes

      delegate :each, to: :nodes

      def initialize(nodes = nil)
        @nodes = nodes || []
        super()
      end

      def append(node)
        nodes << node
        self
      end
      alias << append

      def to_a
        nodes.dup
      end
    end
  end
end
