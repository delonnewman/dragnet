# frozen_string_literal: true

module Dragnet
  module DOM
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Node
    class Node
      include Memoizable

      def self.empty
        @empty ||= new
      end

      # @return [Node, nil]
      attr_accessor :parent

      # @return [Array<Node>]
      attr_accessor :children

      def initialize(parent: nil, children: nil, freeze: true)
        yield self if block_given?
        @parent   ||= parent
        @children ||= children || EMPTY_ARRAY
        self.freeze if freeze
      end

      def concat(node)
        case node
        when NodeList
          node.dup.prepend(self)
        else
          NodeList[self, node]
        end
      end
      alias + concat

      # Return all of the parents of this node
      # @return [Array<Node>]
      def parents
        return EMPTY_ARRAY unless parent

        array = []
        current = parent

        until current.nil?
          array << current
          current = current.parent
        end

        array
      end
      memoize :parents

      # @param [Node] old_child
      # @return [Node]
      def without_child(old_child)
        new do |node|
          node.parent = parent
          node.children = children.filter_map do |child|
            unless child == old_child
              child.with_parent(node)
            end
          end
        end
      end

      # @param [Node] new_child
      # @return [Node]
      def with_child(new_child)
        new do |node|
          node.parent = parent
          node.children = (children + [new_child]).map do |child|
            child.with_parent(node)
          end
        end
      end

      # This only changes the parent of this node the rest of the tree will need to be updated
      # @param [Node] new_parent
      # @return [Node]
      def with_parent(new_parent)
        new(new_parent, children)
      end

      def name
        raise NotImplementedError
      end

      # Return the children of the parent, if there is no parent return an array of this node.
      # @return [Array<Node>]
      def siblings
        return [self] unless parent

        parent.children
      end
      memoize :siblings

      # Return the sibling just be for this node or nil if this node is first
      # @return [Node, nil]
      def previous_sibling
        index = siblings.index(self)
        return if index&.zero?

        siblings[index - 1]
      end

      # Return this sibling just after this node or nil if this node is last
      # @return [Node, nil]
      def next_sibling
        index = siblings.index(self)
        return unless index

        siblings[index + 1]
      end
    end
  end
end
