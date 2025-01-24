# frozen_string_literal: true

module Dragnet
  module UniquelyIdentifiable
    extend ActiveSupport::Concern

    class_methods do
      def find_by_short_id!(short_id)
        find_by!(id: Utils.expand_short_uuid(short_id))
      end
    end

    def short_id
      Utils.shorten_uuid(id)
    end
  end
end
