# frozen_string_literal: true

module Dragnet
  module DOM
    class ElementBuilder
      attr_reader :component, :builder
      attr_accessor :content_in_attributes

      def self.of(component)
        @builders ||= {}
        @builders[component] = new(component)
      end

      def initialize(component)
        Rails.logger.debug "Initializing ElementBuilder for #{component}"
        @component = component
        @builder = HTMLListBuilder.new(component)
      end

      def build_element(tag, attributes, block)
        HTMLElement.new(name: tag) do |node|
          content = evaluate_body(block)
          node.attributes = build_attributes(node, attributes, content)
          node.children = build_children(content)
        end
      end

      def build_void_element(tag, attributes)
        HTMLVoidElement.new(name: tag) do |node|
          node.attributes = build_attributes(node, attributes)
        end
      end

      def evaluate_body(block)
        block ? builder.instance_exec(component, &block) : NodeList.empty
      end

      def build_attributes(node, attributes, content = nil)
        self.content_in_attributes = false
        attributes.reduce({}) do |attrs, pair|
          self.content_in_attributes = content_attribute_value?(content, pair[1])
          process_attribute(node, attrs, pair)
        end
      end

      def process_attribute(node, attrs, pair)
        case pair
        in [:data | 'data', {**values}]
          process_data_attributes(node, attrs, values)
        in [:style | 'style', {**values}]
          process_style_attributes(node, attrs, values)
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

      def content_attribute_value?(content, value)
        return false unless content

        value == content || (value.is_a?(NodeList) && value.include?(content))
      end

      def build_children(content)
        builder.list << content unless content.present? && (content.is_a?(Node) || content_in_attributes)
        builder.list.to_a
      end
    end
  end
end
