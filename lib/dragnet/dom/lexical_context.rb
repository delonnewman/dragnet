# frozen_string_literal: true

module Dragnet
  module DOM
    class LexicalContext < Context
      attr_reader :parent

      # @param [Context, nil] parent
      def initialize(parent)
        @parent = parent
      end

      def list
        @list ||= NodeListProxy.new(HTMLProxy.new(LexicalContext.new(parent)))
      end

      def respond_to_missing?(method, _include_all)
        parent&.respond_to?(method)
      end

      def method_missing(method, *args, **kwargs, &block)
        Rails.logger.debug "Looking for definition #{method.inspect} in #{parent.inspect}"
        super unless parent&.respond_to?(method)

        parent.__send__(method, *args, **kwargs, &block)
      end
    end
  end
end
