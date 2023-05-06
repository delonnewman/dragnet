# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLCompiler
      # @param dom
      # @return [String]
      def compile(dom)
        return compile(dom.template) if dom.is_a?(Class) && dom < Component

        case dom
        when Component
          compile_component(dom)
        when HTMLVoidElement
          compile_void_element(dom)
        when HTMLElement
          compile_element(dom)
        when Comment
          compile_comment(dom)
        when RubyCode
          compile_ruby_code(dom)
        when SafeText
          compile_safe_text(dom)
        when Text
          compile_text(dom)
        when NodeList
          compile_node_list(dom)
        when Attribute
          compile_attribute(dom)
        else
          compile_any(dom)
        end
      end

      # @param node
      # @return [String]
      def compile_any(node)
        CGI.escapeHTML(node.to_s)
      end

      # @param [Component] node
      # @return [String]
      def compile_component(node)
        node.instance_eval(node.compiled_template, __FILE__, __LINE__)
      end

      # @param [Text] node
      # @return [String]
      def compile_text(node)
        return EMPTY_STRING unless node.content

        CGI.escapeHTML(node.content)
      end

      # @param [SafeText] node
      # @return [String]
      def compile_safe_text(node)
        node.content
      end

      # @param [RubyCode] node
      # @return [String]
      def compile_ruby_code(node)
        "<%= #{node.content} %>"
      end

      # @param [Comment] node
      # @return [String]
      def compile_comment(node)
        "<!-- #{node.content} -->"
      end

      # @param [HTMLElement] node
      # @return [String]
      def compile_element(node)
        content = node.children.map { |child| compile(child) }.join('')
        if node.attributes?
          attr_list = node.attributes.map { |(_, a)| compile(a) }.join(' ')
          "<#{node.name} #{attr_list}>#{content}</#{node.name}>"
        else
          "<#{node.name}>#{content}</#{node.name}>"
        end
      end

      # @param [HTMLVoidElement] node
      # @return [String]
      def compile_void_element(node)
        if node.attributes?
          attr_list = node.attributes.map { |_, a| compile(a) }.join(' ')
          "<#{node.name} #{attr_list}>"
        else
          "<#{node.name}>"
        end
      end

      # @param [NodeList] node
      # @return [String]
      def compile_node_list(node)
        node.children.map { compile(_1) }.join('')
      end

      # @param [Attribute] node
      # @return [String]
      def compile_attribute(node)
        unless node.value.is_a?(RubyCode)
          return "#{node.name}=\"#{compile(node.value)}\""
        end

        if node.type == :boolean
          compile_boolean_template(node)
        elsif node.name == 'class'
          compile_class_list_value(node)
        elsif node.name == 'style'
          compile_style_value(node)
        elsif node.name == 'data'
          compile_data_attributes(node, :data)
        elsif node.name == 'aria'
          compile_data_attributes(node, :aria)
        else
          compile_template_value(node)
        end
      end

      def compile_data_attributes(node, prefix)
        template = "Dragnet::DOM::Utils.format_data_attributes(#{node.value.content}, #{prefix.inspect})"
        compile(RubyCode.new(content: template))
      end


      # @param [Attribute] node
      # @return [String]
      def compile_boolean_template(node)
        compile(RubyCode.new(content: "#{node.name.inspect} if #{node.value.content}.present?"))
      end

      # @param [Attribute] node
      # @return [String]
      def compile_template_value(node)
        compile_ruby(node.name, node.value, node.value)
      end

      def compile_class_list_value(node)
        template = "#{node.value.content}.is_a?(Array) ? Dragnet::DOM::Utils.format_class_list(#{node.value.content}) : #{node.value.content}"
        compile_ruby(node.name, node.value, RubyCode.new(content: template))
      end

      def compile_style_value(node)
        template = "#{node.value.content}.is_a?(Hash) ? Dragnet::DOM::Utils.format_style_map(#{node.value.content}) : #{node.value.content}"
        compile_ruby(node.name, node.value, RubyCode.new(content: template))
      end

      def compile_ruby(name, predicate, consequent)
        "<% if #{predicate.content}.present? %>#{name}=\"#{compile(consequent)}\"<% end %>"
      end
    end
  end
end
