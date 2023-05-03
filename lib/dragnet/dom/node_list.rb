# frozen_string_literal: true

module Dragnet
  module DOM
    class NodeList < Node
      delegate :each, :include?, :empty?, to: :children

      def self.empty
        @empty ||= new
      end

      def self.[](*nodes)
        new(nodes)
      end

      def initialize(nodes = nil)
        super(children: nodes || [])
      end

      def concat(node)
        case node
        when NodeList
          self.class.new(to_a + node.to_a)
        else
          dup.append(node)
        end
      end
      alias + concat

      def prepend(node)
        case node
        when NodeList
          node.each do |n|
            children.unshift(n)
          end
        else
          children.unshift(n)
        end

        self
      end
      alias >> prepend

      def append(node)
        case node
        when NodeList
          node.each do |n|
            children << n
          end
        else
          children << node
        end

        self
      end
      alias << append

      def to_a
        children.dup
      end

      def dup
        new(to_a)
      end
    end
  end
end
