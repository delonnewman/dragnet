# frozen_string_literal: true

class SavedReport < ApplicationRecord
  include SelfDescribable

  belongs_to :author, class_name: 'User'
end
