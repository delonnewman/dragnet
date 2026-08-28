class Dragnet::Survey
  module Recording
    extend ActiveSupport::Concern

    included do
      has_many :record_changes, -> { extending RecordChangesExtension },
               class_name: 'Dragnet::RecordChange',
               dependent: :nullify,
               inverse_of: :survey

      enum :record_changes_status, { applied: 0, unapplied: 1, cannot_apply: -1 }

      before_validation :set_default_changes_status

      # Execute code on record changes
      has_many :trigger_registrations,
               class_name: 'Dragnet::TriggerRegistration',
               dependent: :delete_all,
               inverse_of: :survey
    end

    def set_default_changes_status
      self.record_changes_status = :applied unless record_changes_status?
    end
  end
end
