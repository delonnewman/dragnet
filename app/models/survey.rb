# frozen_string_literal: true

class Survey < ApplicationRecord
  include SelfDescribable
  include UniquelyIdentifiable

  belongs_to :author, class_name: 'User'

  # Naming
  validates :name, presence: true
  validates :name, uniqueness: { scope: :author }, on: :create
  with Naming, 'New Survey', delegating: %i[ident generate_name_and_slug]
  before_validation :generate_name_and_slug

  # Questions
  has_many :questions, -> { order(:display_order) }, dependent: :delete_all, inverse_of: :survey
  accepts_nested_attributes_for :questions, allow_destroy: true

  # Record Data
  has_many :replies, dependent: :delete_all, inverse_of: :survey
  has_many :answers, dependent: :delete_all, inverse_of: :survey

  # Analytics
  has_many :ahoy_visits, through: :replies
  with ReplySubmissionPolicy, delegating: %i[visitor_reply_submitted? visitor_reply_created?]
  with DispatchSubmissionRequest, calling: :run

  # To satisfy the Reportable protocol, along with #questions above
  has_many :records, -> { where(submitted: true) }, dependent: :restrict_with_error, inverse_of: :survey, class_name: 'Reply'
  has_many :events, through: :ahoy_visits

  # Editing
  enum :edits_status, { saved: 0, unsaved: 1, cannot_save: -1 }, prefix: :edits
  has_many :edits, -> { where(applied: false) }, class_name: 'SurveyEdit', dependent: :delete_all, inverse_of: :survey
  with Editing, delegating: %i[edited? new_edit current_edit latest_edit latest_edit_valid? set_default_edits_status]
  before_validation :set_default_edits_status

  # Data projection for API integration
  with Projection, calling: :project

  # Copying
  belongs_to :copy_of, class_name: 'Survey', optional: true
  accepts_nested_attributes_for :copy_of, update_only: true, reject_if: ->(attrs) { attrs.compact_blank!.empty? }
  has_many :copies, foreign_key: 'copy_of_id', class_name: 'Survey', dependent: :nullify, inverse_of: :copy_of
  with Copying, delegating: %i[copy! copy copy?]

  has_many :trigger_registrations, dependent: :delete_all, inverse_of: :survey

  with Visibility, delegating: %i[open! close! toggle_visibility!]

  with DataGrid
end
