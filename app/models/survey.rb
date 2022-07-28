# frozen_string_literal: true

class Survey < ApplicationRecord
  include Slugged
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'
  validates :name, presence: true
  validates :name, uniqueness: { scope: :author }, on: :create

  has_many :questions, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :questions, allow_destroy: true

  has_many :replies
  has_many :answers

  has_many :edits, -> { where(applied: false) }, class_name: 'SurveyEdit', dependent: :delete_all
  composes Survey::Editing, delegating: %i[edited? new_edit current_edit latest_edit projection]

  # Initialize, but do not save a new survey record
  #
  # @param author [User]
  # @param attributes [Hash] - survey attributes
  #
  # @return [Survey]
  def self.init(author, attributes = EMPTY_HASH)
    n    = where("name = 'New Survey' or name like 'New Survey (%)' and author_id = ?", author.id).count
    name = n.zero? ? 'New Survey' : "New Survey (#{n})"

    new(attributes.reverse_merge(name: name, author: author))
  end

  # Initialize and save a new survey record
  #
  # @see Survey.init
  def self.init!(*args)
    init(*args).tap(&:save!)
  end
end
