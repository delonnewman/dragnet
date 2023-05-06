# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLProxy
      include HTMLVoidTags
      include HTMLStandardTags

      attr_reader :builder, :context

      # @param [Context, nil] context
      def initialize(context = nil)
        @context = context
        @builder = ElementBuilder.new(context)
      end

      def template?
        context.is_a?(TemplateContext)
      end

      def ruby(content = nil, &block)
        char_element(RubyCode, content, &block)
      end

      def comment(content = nil, &block)
        char_element(Comment, content, &block)
      end

      def text(content = nil, &block)
        char_element(Text, content, &block)
      end

      # TODO: add method for html entities?

      def nbsp(count = 1)
        space(count, non_breaking: true)
      end

      def space(count = nil, non_breaking: false)
        count ||= 1
        spc = non_breaking ? '&nbsp;' : ' '
        Rails.logger.debug "Insert space #{spc.inspect} (#{count})"

        SafeText.new(content: spc * count)
      end

      private

      def char_element(klass, content = nil, **attributes, &block)
        klass = klass.is_a?(Symbol) ? Component.find!(klass) : klass
        if block
          klass.new(**attributes.merge!(content: block.call))
        else
          klass.new(**attributes.merge!(content: content))
        end
      end

      def method_missing(method, *args, **kwargs, &block)
        super unless (comp = Dragnet::Component.find(method))

        Rails.logger.debug "Construct component instance #{comp} #{args.inspect}, #{kwargs.inspect}"
        if template?
          template = comp.bind(*args, **kwargs).template
          return template
        end

        comp.new(**kwargs) do |node|
          node.children = NodeList.coerce(block ? block.call : args)
        end
      end

      def respond_to_missing?(method, _include_all)
        Dragnet::Component.exists?(method)
      end
    end
  end
end
