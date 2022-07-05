# frozen_string_literal: true

class Survey < ApplicationRecord
  include Slugged
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'

  has_many :questions, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :questions

  has_many :replies
  has_many :answers

  def self.init(attributes = EMPTY_HASH)
    n = where("name = 'New Survey' or name like 'New Survey (%)'").count
    name = n.zero? ? 'New Survey' : "New Survey (#{n})"

    new(attributes.reverse_merge(name: name))
  end
end
