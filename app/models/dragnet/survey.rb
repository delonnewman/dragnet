# frozen_string_literal: true

module Dragnet
  class Survey < ApplicationRecord
    include SelfDescribable
    include UniquelyIdentifiable
    include Retractable

    retract_associated :questions, :replies

    belongs_to :author, class_name: 'Dragnet::User'

    # Naming
    validates :name, presence: true
    validates :name, uniqueness: { scope: :author }, on: :create
    with Naming, 'New Survey', delegating: %i[ident generate_name_and_slug]
    before_validation :generate_name_and_slug

    # Questions
    has_many :questions, -> { order(:display_order) }, class_name: 'Dragnet::Question', dependent: :delete_all, inverse_of: :survey
    accepts_nested_attributes_for :questions, allow_destroy: true

    # Record Data
    has_many :replies, class_name: 'Dragnet::Reply', dependent: :delete_all, inverse_of: :survey
    has_many :answers, class_name: 'Dragnet::Answer', dependent: :delete_all, inverse_of: :survey

    # Analytics / Submission
    has_many :ahoy_visits, through: :replies
    has_many :events, through: :replies # Used by StatsReport
    with ReplySubmissionPolicy, delegating: %i[visitor_reply_submitted? visitor_reply_created?]

    def dispatch_submittion_request
      DispatchSubmissionRequest.new(self).run
    end

    def submission_parameters
      SubmissionParametersProjection.new(self).to_h
    end

    # To satisfy the Reportable protocol, along with #questions above
    has_many :records, -> { where(submitted: true) }, class_name: 'Dragnet::Reply', dependent: :restrict_with_error, inverse_of: :survey

    # Editing
    enum :edits_status, { saved: 0, unsaved: 1, cannot_save: -1 }, prefix: :edits
    has_many :edits, -> { where(applied: false) }, class_name: 'Dragnet::SurveyEdit', dependent: :delete_all, inverse_of: :survey
    before_validation { EditingStatus.default!(self) }

    def edited?
      Edits.present?(self)
    end

    def projection
      DataProjection.new(self).to_h
    end

    # Copying
    belongs_to :copy_of, class_name: 'Dragnet::Survey', optional: true
    accepts_nested_attributes_for :copy_of, update_only: true, reject_if: ->(attrs) { attrs.compact_blank!.empty? }
    has_many :copies, foreign_key: 'copy_of_id', class_name: 'Dragnet::Survey', dependent: :nullify, inverse_of: :copy_of

    def copy?
      !copy_of_id.nil?
    end

    # @return [Survey, false]
    def copy!
      s     = copy
      saved = s.save!
      return s if saved

      false
    end

    # @return [Survey]
    def copy
      Survey.new(copy_data)
    end

    # @return [Hash]
    def copy_data
      CopyProjection.new(self).to_h
    end

    # Execute code on record changes
    has_many :trigger_registrations, class_name: 'Dragnet::TriggerRegistration', dependent: :delete_all, inverse_of: :survey

    # DataGrids
    has_many :data_grids, class_name: 'Dragnet::DataGrid', dependent: :delete_all, inverse_of: :survey

    # Record Changes
    has_many :record_changes, class_name: 'Dragnet::RecordChange', dependent: :nullify, inverse_of: :survey
    enum :record_changes_status, { applied: 0, unapplied: 1, cannot_apply: -1 }
    with RecordChangeManagement, delegating: %i[record_changes? new_record_change set_default_changes_status apply_record_changes apply_record_changes!]
    before_validation :set_default_changes_status

    def opened!
      self.open = true
      self
    end

    def open!
      opened!.tap(&:save!)
    end

    def closed!
      self.open = false
      self
    end

    def close!
      closed!.tap(&:save!)
    end
  end
end
