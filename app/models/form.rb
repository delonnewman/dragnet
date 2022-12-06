# frozen_string_literal: true

class Form < ApplicationRecord
  include Slugged
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'
  validates :name, presence: true
  validates :name, uniqueness: { scope: :author }, on: :create

  has_many :fields, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :fields, allow_destroy: true

  has_many :responses
  has_many :response_items

  has_many :edits, -> { where(applied: false) }, class_name: 'FormEdit', dependent: :delete_all
  advised_by Form::Editing, delegating: %i[edited? new_edit current_edit latest_edit projection]

  # Initialize, but do not save, a new survey record. The initialization process will ensure
  # that the survey has a unique name (relative to the author).
  #
  # @param author [User]
  # @param attributes [Hash] - survey attributes
  #
  # @return [Form]
  def self.init(author, attributes = EMPTY_HASH)
    n    = where("name = 'New Form' or name like 'New Form (%)' and author_id = ?", author.id).count
    name = n.zero? ? 'New Form' : "New Form (#{n})"

    new(attributes.reverse_merge(name: name, author: author))
  end

  # Initialize and save a new survey record
  #
  # @see Survey.init
  #
  # @return [Form]
  def self.init!(*args)
    init(*args).tap(&:save!)
  end
end
