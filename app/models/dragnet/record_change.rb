# frozen_string_literal: true

module Dragnet
  class RecordChange < ApplicationRecord
    belongs_to :survey, class_name: 'Dragnet::Survey', inverse_of: :record_changes

    serialize :changes
    serialize :diff

    with TriggerExecutionManagement
    after_create { trigger_execution.async.execute_triggers }

    # @return [Class<ActiveRecord::Base>]
    def record_class
      record_class_name.constantize
    end

    # @return [ActiveRecord::Base, Retractable]
    def record
      record_class.find(record_id)
    end
    memoize :record

    def generated_diff
      record.attributes.each_with_object({}) do |(key, value), diff|
        diff[key] = [changes[key], value]
      end
    end

    # @param [Time] timestamp
    #
    # @return [RecordChange]
    def applied!(timestamp)
      self.applied = true
      self.applied_at = timestamp
      self.diff = generated_diff
      self
    end

    # @param [Time] timestamp
    #
    # @return [false, ActiveRecord::Base]
    def apply_changes(timestamp)
      if retraction?
        record.retract(timestamp)
      else
        # FIXME: this should create only not update
        record.update(changes.merge(updated_at: timestamp))
      end
    end

    # @param [Time] timestamp
    #
    # @raise ActiveRecord::RecordInvalid
    #
    # @return [ActiveRecord::Base]
    def apply_changes!(timestamp)
      if retraction?
        record.retract!(timestamp)
      else
        # FIXME: this should create only not update
        record.update!(changes.merge(updated_at: timestamp))
      end
    end

    def apply(timestamp = Time.zone.now)
      RecordChange.transaction do
        apply_changes(timestamp) && applied!(timestamp).save
      end
    end

    def apply!(timestamp = Time.zone.now)
      RecordChange.transaction do
        apply_changes!(timestamp)
        applied!(timestamp).save!
      end
    end
  end
end