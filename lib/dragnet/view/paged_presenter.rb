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
        raise NoMethodError
      end

      def records
        raise NoMethodError
      end

      # @return [Integer]
      def items
        params.fetch(:items, default_items).to_i
      end

      # @return [Integer]
      def page
        page = params.fetch(:page, 1).to_i
        return 1 if page < 1
        page
      end
    end
  end
end
