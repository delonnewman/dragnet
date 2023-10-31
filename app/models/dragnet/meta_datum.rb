# frozen_string_literal: true

module Dragnet
  class MetaDatum < ApplicationRecord
    belongs_to :self_describable, polymorphic: true, inverse_of: :meta_data_records
  end
end
