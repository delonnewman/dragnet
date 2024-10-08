# frozen_string_literal: true

module Dragnet
  module View
    class PagedPresenter < Presenter
      DEFAULT_ITEMS = 10

      class << self
        def default_items(items = nil)
          return @default_items || DEFAULT_ITEMS unless items

          @default_items = items
        end
      end

      delegate :default_items, to: :class

      # @return [Pagy]
      def pager
        raise NotImplementedError
      end

      def records
        raise NotImplementedError
      end

      # @return [Integer]
      def items
        params.fetch(:items, default_items).to_i
      end

      # @return [Integer]
      def page
        params.fetch(:page, 1).to_i
      end
    end
  end
end
