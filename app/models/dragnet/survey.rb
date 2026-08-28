# frozen_string_literal: true

module Dragnet
  class Survey < ApplicationRecord
    include SelfDescribable
    include UniquelyIdentifiable
    include Retractable
    include Presentable

    retract_associated :questions, :replies

    belongs_to :author, class_name: 'Dragnet::User'

    # Naming
    validates :name, presence: true, uniqueness: { scope: :author }, on: :create
    before_validation { Name.assign!(self) }

    # Questions
    has_many :questions, -> { order(:display_order) }, class_name: 'Dragnet::Question', dependent: :delete_all, inverse_of: :survey
    accepts_nested_attributes_for :questions, allow_destroy: true

    def types
      questions.map { it.type.class }
    end

    # Treat surveys as whole values
    scope :whole, -> { eager_load(:author, questions: %i[question_options]) }

    # Record Data
    has_many :replies, class_name: 'Dragnet::Reply', dependent: :delete_all, inverse_of: :survey
    has_many :answers, class_name: 'Dragnet::Answer', dependent: :delete_all, inverse_of: :survey

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

    # Survey specific mixins
    include Reporting
    include Submissions
    include Editing
    include Copying
  end
end
