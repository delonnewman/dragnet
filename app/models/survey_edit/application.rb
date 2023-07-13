# frozen_string_literal: true

# Logic for applying survey edits to a survey to preserve the changes
class SurveyEdit::Application < Dragnet::Advice
  advises SurveyEdit, as: :edit

  attr_reader :validating_survey

  delegate :valid?, :validate!, :errors, to: :validating_survey
  delegate :survey, to: :edit

  # @param [SurveyEdit] edit
  def initialize(edit)
    super(edit)
    @validating_survey = Survey.new(edit.survey_attributes)
  end

  # @param [Time] timestamp
  # @return [SurveyEdit]
  def applied(timestamp = Time.zone.now)
    return false unless valid?(:application)

    edit.applied = true
    edit.applied_at = timestamp
    edit
  end

  # @param [Time] timestamp
  # @return [SurveyEdit]
  def applied!(timestamp = Time.zone.now)
    validate!(:application)
    applied(timestamp)
  end

  # @return [void]
  def set_survey_edits_status
    return if edit.applied?

    if valid?
      survey.update(edits_status: :unsaved)
    else
      survey.update(edits_status: :cannot_save)
    end
  end

  # @param [Time] timestamp
  #
  # @raise [ActiveRecord::RecordInvalid]
  #
  # @return [Survey, Class<ActiveRecord::Rollback>]
  def apply!(timestamp = Time.now)
    SurveyEdit.transaction do
      # Mark as published and validate without saving
      unless applied(timestamp)
        edit.errors.merge!(errors)
        raise ActiveRecord::RecordInvalid, edit
      end

      # Commit changes to survey
      survey.update!(edit.survey_attributes.merge(updated_at: timestamp, edits_status: :saved))

      # Save changes to edit
      edit.save!

      # Clean up old drafts
      survey.edits.where.not(id: edit.id).delete_all

      survey
    end
  end

  # @param [Time] timestamp
  #
  # @raise [ActiveRecord::RecordInvalid]
  #
  # @return [Survey, Class<ActiveRecord::Rollback>, false]
  def apply(timestamp = Time.zone.now)
    apply!(timestamp)
  rescue ActiveRecord::RecordInvalid
    false
  end
end
