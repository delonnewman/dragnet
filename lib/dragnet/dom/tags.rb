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
              h.merge!(k.name => Attribute.new(element: node, name: k.name.tr('_', '-'), value: v))
            end
            builder = HTMLListBuilder.new(self)
            content = builder.instance_exec(&block)
            builder.list << content unless content.is_a?(Node)
            node.children = builder.list.to_a
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
              h.merge!(k.name => Attribute.new(element: node, name: k.name.tr('_', '-'), value: v))
            end
          end
        end

        registered_tags[method_name] = tag

        method_name
      end
    end
  end
end
