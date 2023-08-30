# frozen_string_literal: true

class TriggerExecution < ApplicationRecord
  belongs_to :trigger_registration, inverse_of: :TriggerExecutionManagement
  enum :status, { initialized: 0, pending: 1, success: 2, failure: -1 }
end
