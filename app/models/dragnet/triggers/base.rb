# frozen_string_literal: true

module Dragnet
  module Triggers
    class Base
      attr_reader :registration, :record_change, :execution

      # @param [TriggerRegistration] registration
      # @param [RecordChange] record_change
      # @param [TriggerExecution] execution
      def initialize(registration, record_change, execution)
        @registration  = registration
        @record_change = record_change
        @execution     = execution
      end

      def execute
        raise NotImplementedError, 'subclasses should implement an execute method'
      end
    end
  end
end
