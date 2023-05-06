# frozen_string_literal: true

module Dragnet
  module DOM
    class ElementBuilder
      attr_reader :context

      # @param [Context, nil] context
      def initialize(context)
        Rails.logger.debug "Initializing ElementBuilder for #{context}"
        @context = LexicalContext.new(context)
      end

      def build_element(tag, attributes, content, block)
        HTMLElement.new(name: tag) do |node|
          node.attributes = build_attributes(node, attributes)
          content = evaluate_body(block) unless content
          node.children = NodeList.coerce(content) if content
        end
      end

      def evaluate_body(block)
        block ? context.instance_exec(&block) : nil
      end

      def build_void_element(tag, attributes)
        HTMLVoidElement.new(name: tag) do |node|
          node.attributes = build_attributes(node, attributes)
        end
      end

      def build_attributes(node, attributes)
        attributes.reduce({}) do |attrs, pair|
          process_attribute(node, attrs, pair)
        end
      end

      def process_attribute(node, attrs, pair)
        case pair
        in [:data | 'data', {**values}]
          process_data_attributes(node, attrs, :data, values)
        in [:aria | 'aria', {**values}]
          process_data_attributes(node, attrs, :aria, values)
        in [:style | 'style', {**values}]
          process_style_attributes(node, attrs, values)
        in [:class | 'class', [*values]]
          process_class_list_attribute(node, attrs, values)
        in [*, nil | false]
          attrs
        else
          (name, value) = pair
          attrs.merge!(name.name => Attribute.new(element: node, name: name.name.tr('_', '-'), value: value))
        end
      end

      def process_data_attributes(node, attrs, prefix, values)
        Utils.collect_data_attributes(values, prefix).each do |(name, value)|
          attrs[name] = Attribute.new(element: node, name: name, value: value)
        end
        attrs
      end

      def process_style_attributes(node, attrs, values)
        value = Utils.format_style_map(values)
        attrs['style'] = Attribute.new(element: node, name: 'style', value: value)
        attrs
      end

      def process_class_list_attribute(node, attrs, values)
        value = Utils.format_class_list(values)
        attrs['class'] = Attribute.new(element: node, name: 'class', value: value)
        attrs
      end
    end
  end
end
