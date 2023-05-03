# frozen_string_literal: true

module Dragnet
  module DOM
    class NodeList < Node
      attr_reader :nodes

      delegate :each, :include?, :empty?, to: :nodes

      def self.empty
        @empty ||= new
      end


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
