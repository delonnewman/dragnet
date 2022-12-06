# frozen_string_literal: true

# Logic for survey edit application
class FormEdit::Application < Dragnet::Advice
  advises FormEdit, as: :edit

  attr_reader :validating_form

  delegate :valid?, :validate!, :errors, to: :validating_form

  def initialize(edit)
    super(edit)
    @validating_form = Form.new(edit.form_attributes)
  end

  def applied(timestamp = Time.now)
    edit.applied = true
    edit.applied_at = timestamp
    edit
  end

  def applied!(timestamp = Time.now)
    validate!(:application)
    applied(timestamp)
  end

  def apply!(timestamp = Time.now)
    FormEdit.transaction do
      # Commit changes to survey
      edit.form.update(edit.form_attributes.merge(updated_at: timestamp))

      # Mark this draft as published
      applied!(timestamp).save!

      # Clean up old drafts
      edit.form.edits.where.not(id: edit.id).delete_all

      edit.form
    end
  end
end
