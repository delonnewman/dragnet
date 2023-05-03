# frozen_string_literal: true

module Dragnet
  module DOM
    class ElementBuilder
      attr_reader :component, :proxy
      attr_accessor :content_in_attributes

      def self.of(component)
        @builders ||= {}
        @builders[component] = new(component)
      end

      def initialize(component)
        Rails.logger.debug "Initializing ElementBuilder for #{component}"
        @component = component
        @proxy = NodeListProxy.new(HTMLProxy.new(component))
      end

      def build_element(tag, attributes, block)
        HTMLElement.new(name: tag) do |node|
          node.attributes = build_attributes(node, attributes)
          content = evaluate_body(block)
          node.children = build_children(content) if content
        end
      end

      def evaluate_body(block)
        block ? proxy.instance_exec(component, &block) : nil
      end

      def build_children(content)
        case content
        when NodeList
          content.to_a
        else
          [content]
        end
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
          process_data_attributes(node, attrs, values)
        in [:style | 'style', {**values}]
          process_style_attributes(node, attrs, values)
        in [:class | 'class', [*values]]
          process_class_list_attribute(node, attrs, values)
        in [*, nil]
          attrs
        else
          (name, value) = pair
          attrs.merge!(name.name => Attribute.new(element: node, name: name.name.tr('_', '-'), value: value))
        end
      end

      def process_data_attributes(node, attrs, values)
        values.each_pair do |key, value|
          name = "data-#{key.name.tr('_', '-')}"
          attrs[name] = Attribute.new(element: node, name: name, value: value)
        end
        attrs
      end

      def process_style_attributes(node, attrs, values)
        value = values.map do |(k, v)|
          v = v.is_a?(Numeric) ? "#{v}px" : v
          "#{k}: #{v}"
        end.join('; ')
        attrs['style'] = Attribute.new(element: node, name: 'style', value: value)
        attrs
      end

      def process_class_list_attribute(node, attrs, values)
        value = values.join(' ')
        attrs['class'] = Attribute.new(element: node, name: 'class', value: value)
        attrs
      end
    end
  end
end
