# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLBuilder
      include HTMLVoidTags
      include HTMLStandardTags

      attr_reader :component

      def initialize(component)
        @component = component
      end

      def attributes
        @attributes ||= Hash.new do |_, key|
          ruby("attributes[#{key.inspect}]")
        end
      end

      def ruby(content = nil, &block)
        if content
          RubyCode.new(content: content)
        else
          RubyCode.new(content: block.call)
        end
      end

      def comment(content = nil, &block)
        if content
          Comment.new(content: content)
        else
          Comment.new(content: block.call)
        end
      end

      def text(content = nil, &block)
        if content
          Text.new(content: content)
        else
          Text.new(content: block.call)
        end
      end

      # TODO: add method for html entities?

      def nbsp(count = 1)
        space(count, non_breaking: true)
      end

      def space(count = nil, non_breaking: false)
        count ||= 1
        spc = non_breaking ? '&nbsp;' : ' '

        Text.new(content: spc * count)
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
          return comp.new(**kwargs)
        end

        if args.present? && kwargs.present?
          ruby("#{method}(*#{args.inspect}, **#{kwargs.inspect})")
        elsif args.present?
          ruby("#{method}(*#{args.inspect})")
        elsif kwargs.present?
          ruby("#{method}(**#{kwargs.inspect})")
        else
          ruby("#{method}")
        end
      end

      def respond_to_missing?(method, include_all)
        component.method_defined?(method, include_all) || Dragnet::Component.find(method)
      end
    end
  end
end
