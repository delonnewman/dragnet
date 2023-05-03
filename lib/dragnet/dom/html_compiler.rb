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

      # @return [String]
      def compile_any(node)
        node.to_s
      end

      # @param [Component] node
      # @return [String]
      def compile_component(node)
        node.instance_eval(node.compiled_template)
      end

      # @param [Text] node
      # @return [String]
      def compile_text(node)
        return EMPTY_STRING unless node.content

        CGI.escapeHTML(node.content)
      end

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
          attr_list = node.attributes.map do |(_, a)|
            compile(a)
          end
          "<#{node.name} #{attr_list.join(' ')}>#{content}</#{node.name}>"
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
        node.nodes.map { compile(_1) }.join('')
      end

      # @param [Attribute] node
      # @return [String]
      def compile_attribute(node)
        if node.type == :boolean && node.value.is_a?(RubyCode)
          compile(RubyCode.new(content: "#{node.value.content} ? '#{node.name}' : ''"))
        elsif node.type == :code && node.value.is_a?(RubyCode)
          "#{node.name}=\"#{compile(RubyCode.new(content: "Ruby2JS.convert(#{node.value.content}, preset: true)"))}\""
        else
          "#{node.name}=\"#{compile(node.value)}\""
        end
      end
    end
  end
end
