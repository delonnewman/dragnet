# frozen_string_literal: true

module Dragnet
  class TriggerExecution < ApplicationRecord
    belongs_to :trigger_registration, class_name: 'Dragnet::TriggerRegistration', inverse_of: :trigger_executions
    enum :status, { initialized: 0, pending: 1, success: 2, failure: -1 }
  end
end
