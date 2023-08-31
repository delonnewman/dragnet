# frozen_string_literal: true

module Dragnet
  class MetaDatum < ApplicationRecord
    belongs_to :self_describable, polymorphic: true
  end
end
