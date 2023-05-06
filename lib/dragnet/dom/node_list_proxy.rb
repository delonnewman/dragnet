# frozen_string_literal: true

module Dragnet
  module DOM
    class NodeListProxy
      attr_reader :tag_proxy, :list

      # @param [HTMLProxy] tag_proxy
      def initialize(tag_proxy = HTMLProxy.new)
        @tag_proxy = tag_proxy
        @list = NodeList.new
      end

      private

      delegate :respond_to_missing?, to: :tag_proxy

      def method_missing(method, *args, **kwargs, &block)
        super unless tag_proxy.respond_to?(method)

        Rails.logger.debug "Forward method to HTMLBuilder #{method} #{args.inspect} #{kwargs.inspect}"
        list << tag_proxy.__send__(method, *args, **kwargs, &block)
      end
    end
  end
end
