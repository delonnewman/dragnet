# frozen_string_literal: true

module Dragnet
  module DOM
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Element
    class Element < Node
      include Elemental

      # @return [String]
      attr_accessor :name

      # @return [Hash{String => Attribute}]
      attr_accessor :attributes

      def initialize(name: nil, attributes: nil, **args, &_)
        super(freeze: false, **args, &_)
        @name       ||= name       || 'empty'
        @attributes ||= attributes || EMPTY_HASH
        freeze
      end

      def deconstruct
        [tag, attributes.transform_values(&:value), children]
      end

      def deconstruct_keys(*) = to_h.merge(tag: tag)

      def to_h
        {
          name: name,
          attributes: attributes.transform_values(&:value),
          children: children.map do |child|
            child.respond_to?(:to_h) ? child.to_h : child
          end
        }
      end

      def tag
        name.to_sym
      end

      def attributes?
        !attributes.empty?
      end

      # @return [String]
      def id
        attribute('id')
      end

      # @return [Array<String>]
      def class_list
        class_name.split
      end
      memoize :class_list

      # @return [String]
      def class_name
        attribute('class')
      end

      # @param [String, Symbol] attr_name
      # @return [String]
      def attribute(attr_name)
        attribute_node(attr_name).value
      end
      alias get_attribute attribute

      # @param [String, Symbol] attr_name
      # @return [Attribute]
      def attribute_node(attr_name)
        sym = attr_name.to_sym
        return Attribute.empty unless attributes.key?(sym)

        attributes[sym]
      end
      alias get_attribute_node attribute_node

      # @return [Array<String>]
      def attribute_names
        attributes.keys
      end
      alias get_attribute_names attribute_names
    end
  end
end
