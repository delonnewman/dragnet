# frozen_string_literal: true

module Dragnet
  # Logic for record changes in the data grid
  module Survey::RecordChangesExtension
    # @param [ActiveRecord::Base] record
    # @param [Hash] changes
    #
    # @return [RecordChange]
    def build_from_changes(record, changes)
      RecordChange.new(
        survey:            survey,
        record_class_name: record.class.name,
        record_id:         record.id,
        changes:           changes.presence
      )
    end

    def empty?
      survey.record_changes.exists?(applied: false)
    end

    def apply
      result = true
      RecordChange.transaction do
        survey.record_changes.find_each do |change|
          result &&= (change.apply_changes(timestamp) && change.applied!(timestamp).save)
        end
      end
      result
    end

    def apply!
      RecordChange.transaction do
        survey.record_changes.find_each do |change|
          change.apply_changes!(timestamp)
          change.applied!(timestamp).save!
        end
      end
    end
  end
end
