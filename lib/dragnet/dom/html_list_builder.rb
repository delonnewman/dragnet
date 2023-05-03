# frozen_string_literal: true

module Dragnet
  module DOM
    class HTMLListBuilder
      attr_reader :html, :list

      def initialize(html_builder)
        @html = html_builder
        @list = NodeList.new
      end

      private

      delegate :respond_to_missing?, to: :html

      def method_missing(method, *args, **kwargs, &block)
        Rails.logger.debug "Forward method to HTMLBuilder #{method} #{args.inspect} #{kwargs.inspect}"
        result = html.__send__(method, *args, **kwargs, &block)
        Rails.logger.debug "Collect result into NodeList #{result.inspect}"
        list << result
        result
      end
    end
  end
end
