# frozen_string_literal: true

module Dragnet
  module DOM
    # Represents the the attributes of an element
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Attr
    class Attribute < Node
      # Attributes *qualified* name. If the attribute is not in a namespace it will be the same as
      # the local_name attribute.
      # @return [String]
      attr_accessor :name

      # The attribute's value
      attr_accessor :value

      def initialize(name: nil, value: nil, element: nil, &_)
        super(parent: element, freeze: false, &_)
        @name   ||= name  || EMPTY_STRING
        @value  ||= value || EMPTY_STRING
      end

      def prefix
        name_parts.first
      end

      def local_name
        name_parts.last
      end

      private

      def name_parts
        name.split(':')
      end
    end
  end
end
