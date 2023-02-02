# frozen_string_literal: true

class Survey < ApplicationRecord
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'
  validates :name, presence: true
  validates :name, uniqueness: { scope: :author }, on: :create
  with Survey::Naming, 'New Survey', delegating: %i[ident generate_naming!]
  after_initialize :generate_naming!

  has_many :questions, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :questions, allow_destroy: true

  has_many :replies
  has_many :answers

  has_many :edits, -> { where(applied: false) }, class_name: 'SurveyEdit', dependent: :delete_all
  with Survey::Editing, delegating: %i[edited? new_edit current_edit latest_edit]
  with Survey::Projection, calling: :project
end
