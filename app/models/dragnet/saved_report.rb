# frozen_string_literal: true

module Dragnet
  class SavedReport < ApplicationRecord
    include SelfDescribable

    belongs_to :author, class_name: 'Dragnet::User'
  end
end
