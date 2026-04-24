# frozen_string_literal: true

module Dragnet
  class SavedReport < ApplicationRecord
    include SelfDescribable

    belongs_to :author, class_name: 'Dragnet::User'
    has_many :question_aliases, as: :reportable
  end
end
