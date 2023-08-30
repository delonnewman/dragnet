# frozen_string_literal: true

class TriggerRegistration < ApplicationRecord
  belongs_to :survey
  has_many :trigger_executions, inverse_of: :trigger_registration, dependent: :nullify

  def trigger_class
    trigger_class_name.constantize
  end
end
