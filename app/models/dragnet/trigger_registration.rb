# frozen_string_literal: true

module Dragnet
  class TriggerRegistration < ApplicationRecord
    belongs_to :survey, class_name: 'Dragnet::Survey', inverse_of: :trigger_registrations
    has_many :trigger_executions, class_name: 'Dragnet::TriggerExecution', inverse_of: :trigger_registration, dependent: :nullify

    def trigger_class
      trigger_class_name.constantize
    end
  end
end
