# frozen_string_literal: true

module Dragnet
  class MetaDatum < ApplicationRecord
    belongs_to :self_describable, polymorphic: true, inverse_of: :meta_data_records

    def self.build(attributes)
      case attributes
      when Array
        attributes.map do |attributes|
          new(attributes)
        end
      else
        new(attributes)
      end
    end
  end
end
