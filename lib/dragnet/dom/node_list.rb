# frozen_string_literal: true

module Dragnet
  module DOM
    class NodeList < Node
      include Enumerable

      delegate :each, :include?, :empty?, to: :nodes

      def self.empty
        @empty ||= new
      end

      def self.coerce(obj)
        case obj
        when self
          obj
        when Array
          new(obj)
        when Hash
          new do |node|
            node.children = obj.map do |(k, v)|
              Attribute.new(element: node, name: k.to_s, value: v)
            end
          end
        when Enumerable
          new(obj.to_a)
        else
          new([obj])
        end
      end

      def self.[](*nodes)
        new(nodes)
      end

      def initialize(nodes = nil)
        @nodes = nodes || []
        super()
      end

      def children
        NodeList.new(nodes)
      end

      def children=(nodes)
        list = NodeList.coerce(nodes)
        self.nodes = list.to_a
      end

      def concat(node)
        case node
        when Enumerable
          self.class.new(to_a + node.to_a)
        else
          dup.append(node)
        end
      end
      alias + concat

      def prepend(node)
        case node
        when Enumerable
          node.each do |n|
            nodes.unshift(n)
          end
        else
          nodes.unshift(node)
        end

        self
      end
      alias >> prepend

      def append(node)
        case node
        when Enumerable
          node.each do |n|
            nodes << n
          end
        else
          nodes << node
        end

        self
      end
      alias << append

      def to_a
        nodes.dup
      end

      def to_h
        nodes.reduce({}) do |h, child|
          if child.is_a?(Attribute)
            h.merge!(child.name => child.value)
          else
            raise TypeError, "#{child.class} can't be coerced into a Hash pair"
          end
        end
      end

      def dup
        self.class.new(to_a)
      end

      private

      attr_accessor :nodes
    end
  end
end
