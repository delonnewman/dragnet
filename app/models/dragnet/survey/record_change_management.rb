# frozen_string_literal: true

# Logic record changes in the data grid
class Dragnet::Survey::RecordChangeManagement < Dragnet::Advice
  advises Survey

  def set_default_changes_status
    survey.record_changes_status = :applied unless survey.record_changes_status?
  end

  # @param [ActiveRecord::Base] record
  # @param [Hash] changes
  #
  # @return [RecordChange]
  def new_record_change(record, changes)
    RecordChange.new(
      survey:            survey,
      record_class_name: record.class.name,
      record_id:         record.id,
      changes:           changes.presence
    )
  end

  def record_changes?
    survey.record_changes.exists?(applied: false)
  end

  def apply_record_changes
    result = true
    RecordChange.transaction do
      survey.record_changes.find_each do |change|
        result &&= (change.apply_changes(timestamp) && change.applied!(timestamp).save)
      end
    end
    result
  end

  def apply_record_changes!
    RecordChange.transaction do
      survey.record_changes.find_each do |change|
        change.apply_changes!(timestamp)
        change.applied!(timestamp).save!
      end
    end
  end
end
