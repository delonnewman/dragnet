# frozen_string_literal: true

module Dragnet
  module UniquelyIdentifiable
    extend ActiveSupport::Concern

    ALPHABET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_~'.chars.freeze

    class_methods do
      def find_by_short_id!(short_id)
        find_by!(id: ShortUUID.expand(short_id, ALPHABET))
      end
    end

    def short_id
      ShortUUID.shorten(id, ALPHABET)
    end
  end
end