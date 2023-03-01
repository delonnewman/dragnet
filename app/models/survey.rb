# frozen_string_literal: true

class Survey < ApplicationRecord
  include SelfDescribable
  include UniquelyIdentifiable

  belongs_to :author, class_name: 'User'
  validates :name, presence: true
  validates :name, uniqueness: { scope: :author }, on: :create

  with Naming, 'New Survey', delegating: %i[ident generate_name_and_slug]
  before_validation :generate_name_and_slug

  has_many :questions, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :questions, allow_destroy: true

  has_many :replies, -> { where(submitted: true) }, dependent: :delete_all
  has_many :answers

  enum :edits_status, { saved: 0, unsaved: 1, cannot_save: -1 }, prefix: :edits
  has_many :edits, -> { where(applied: false) }, class_name: 'SurveyEdit', dependent: :delete_all
  with Editing, delegating: %i[edited? new_edit current_edit latest_edit latest_edit_valid?]

  with Projection, calling: :project

  belongs_to :copy_of, class_name: 'Survey', optional: true
  accepts_nested_attributes_for :copy_of
  has_many :copies, foreign_key: 'copy_of_id', class_name: 'Survey'
  with Copying, delegating: %i[copy! copy copy?]
end
