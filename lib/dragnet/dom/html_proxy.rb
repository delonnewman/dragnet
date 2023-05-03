# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLProxy
      include HTMLVoidTags
      include HTMLStandardTags

      attr_reader :component

      def initialize(component)
        Rails.logger.debug "Initializing HTMLProxy for #{component}"
        @component = component
      end

      def to_s
        "#<#{self.class}(#{component})>"
      end
      alias inspect to_s

      def attributes
        @attributes ||= Hash.new do |_, key|
          ruby("attributes[#{key.inspect}]")
        end
      end

      def ruby(content = nil, &block)
        element(RubyCode, content, &block)
      end

      def comment(content = nil, &block)
        element(Comment, content, &block)
      end

      def text(content = nil, &block)
        element(Text, content, &block)
      end

      def element(klass, content = nil, **attributes, &block)
        klass = klass.is_a?(Symbol) ? Component.find!(klass) : klass
        if block
          klass.new(**attributes.merge!(content: block.call))
        else
          klass.new(**attributes.merge!(content: content))
        end
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

      def method_missing(method, *args, **kwargs, &block)
        comp = nil

        unless component.method_defined?(method) || (comp = Dragnet::Component.find(method))
          raise NoMethodError, "undefined method `#{method}' for #{component}"
        end

        if comp
          attrs = kwargs
          attrs.merge!(content: block.call) if block_given?
          Rails.logger.debug "Construct component instance #{comp} #{attrs.inspect}"
          return comp.new(**kwargs)
        end

        Rails.logger.debug "Construct method invocation #{method} #{args.inspect} #{kwargs.inspect}"

        if args.present? && kwargs.present?
          ruby("#{method}(*#{eval_args(args).inspect}, **#{eval_kwargs(kwargs).inspect})")
        elsif args.present?
          ruby("#{method}(*#{eval_args(args).inspect})")
        elsif kwargs.present?
          ruby("#{method}(**#{eval_kwargs(kwargs).inspect})")
        else
          ruby("#{method}")
        end
      end

      def respond_to_missing?(method, include_all)
        component.method_defined?(method, include_all) || Dragnet::Component.find(method)
      end

      def eval_kwargs(kwargs)
        kwargs.transform_values do |v|
          v.respond_to?(:content) ? v.content : v
        end
      end

      def eval_args(args)
        args.map do |v|
          v.respond_to?(:content) ? v.content : v
        end
      end
    end
  end
end
