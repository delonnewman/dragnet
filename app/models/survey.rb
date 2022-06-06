# frozen_string_literal: true

class Survey < ApplicationRecord
  include Slugged
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'

  has_many :questions, dependent: :delete_all
  accepts_nested_attributes_for :questions

  has_many :replies
  has_many :answers
end
