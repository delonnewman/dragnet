# frozen_string_literal: true

class MetaDatum < ApplicationRecord
  belongs_to :self_describing, polymorphic: true
end
