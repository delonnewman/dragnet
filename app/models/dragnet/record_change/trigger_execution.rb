# frozen_string_literal: true

module Dragnet
  class RecordChange::TriggerExecution < Advice
    advises RecordChange, as: :change
    include Concurrent::Async

    def execute_triggers
      survey.trigger_registrations.find_each do |registration|
        execution = registration.trigger_executions.create!(status: :initialized)
        registration.trigger_class.new(registration, change, execution).call
      end
    end
  end
end
