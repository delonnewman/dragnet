# frozen_string_literal: true

module Dragnet
  module DOM
    class TemplateContext < Context
      attr_reader :component

      def initialize(component)
        Rails.logger.debug "Initializing TemplateContext for #{component}"
        @component = component
      end

      def tag
        @tag ||= HTMLProxy.new(self)
      end

      def attributes
        @attributes ||= Hash.new do |_, key|
          tag.ruby("attributes[#{key.inspect}]")
        end
      end

      def method_missing(method, *args, **kwargs, &block)
        Rails.logger.debug "Construct method invocation #{method} #{args.inspect} #{kwargs.inspect}"

        if args.present? && kwargs.present?
          tag.ruby("#{method}(#{fmt_args(args)}, #{fmt_kwargs(kwargs)})")
        elsif args.present?
          tag.ruby("#{method}(#{fmt_args(args)})")
        elsif kwargs.present?
          tag.ruby("#{method}(#{fmt_kwargs(kwargs)})")
        else
          tag.ruby("#{method}")
        end
      end

      def respond_to_missing?(method, _include_all)
        component.method_defined?(method)
      end

      private

      def fmt_kwargs(kwargs)
        kwargs.transform_values { |v| v.respond_to?(:content) ? v.content : v }
              .map { |(k, v)| "#{k}: #{v}" }.join(', ')
      end

      def fmt_args(args)
        args.map { |v| v.respond_to?(:content) ? v.content : v }
            .join(', ')
      end
    end
  end
end
