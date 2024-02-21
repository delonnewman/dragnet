# frozen_string_literal: true

module Dragnet
  module SelfDescribable
    extend ActiveSupport::Concern

    included do
      attribute :meta_data, :json
    end

    def meta
      @meta ||= MetaData.new(self)
    end

    def meta=(data_hash)
      meta.update_data!(data_hash)
    end
  end
end
