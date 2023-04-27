# frozen_string_literal: true

module Dragnet
  module DOM
    module Tags
      # @api private
      def registered_tags
        @registered_tags ||= Concurrent::Map.new
      end

      def register_tag(method_name, tag: nil)
        tag ||= method_name.name.tr('_', '-')

        define_method method_name do |**attributes, &block|
          HTMLElement.new(name: tag) do |node|
            node.attributes = attributes.reduce({}) do |h, (k, v)|
              h.merge!(k.name => Attribute.new(element: node, name: k.name, value: v))
            end
            children = block.call || EMPTY_ARRAY
            children = [children] unless children.is_a?(Array)
            node.children = children
          end
        end

        registered_tags[method_name] = tag

        method_name
      end

      def register_void_tag(method_name, tag: nil)
        tag ||= method_name.name.tr('_', '-')

        define_method method_name do |**attributes|
          HTMLVoidElement.new(name: tag) do |node|
            node.attributes = attributes.reduce({}) do |h, (k, v)|
              h.merge!(k.name => Attribute.new(element: node, name: k.name, value: v))
            end
          end
        end

        registered_tags[method_name] = tag

        method_name
      end
    end
  end
end
