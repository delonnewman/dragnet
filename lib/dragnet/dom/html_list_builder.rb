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
        list << html.public_send(method, *args, **kwargs, &block)
      end
    end
  end
end
