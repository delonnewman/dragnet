# frozen_string_literal: true

module Dragnet
  module DOM
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Document
    class Document < Node
      include Elemental

      # @return [String]
      attr_accessor :content_type

      # @return [String]
      attr_accessor :doctype

      # @return [Element, nil]
      attr_accessor :document_element

      # @return [String]
      attr_accessor :document_uri
      alias url document_uri

      def initialize(document_element: nil, document_uri: nil, &_)
        super(freeze: false, &_)

        @document_uri ||= document_uri
        @document_element ||= document_element
        @children ||= document_element ? [document_element] : EMPTY_ARRAY

        freeze
      end

      def name
        '#document'
      end

      def body
        return unless document_element

        find_child_element('body', 'frameset')
      end

      def head
        find_child_element('head')
      end

      def title
        find_child_element('title')
      end

      private

      # @return [Element, nil]
      def find_child_element(*names)
        document_element.child_elements.find do |node|
          names.include?(node.name)
        end
      end
    end
  end
end
