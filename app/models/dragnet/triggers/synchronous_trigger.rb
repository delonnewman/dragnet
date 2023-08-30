# frozen_string_literal: true

module Dragnet
  module Triggers
    class SynchronousTrigger < Base
      def call
        execution.update!(status: :pending)
        value = execute
        execution.update!(status: :success, output: value, completed: true, completed_at: Time.zone.now)
      rescue => e
        execution.update!(
          status:       :failure,
          output:       e.message + "\n" + e.backtrace.to_s,
          completed:    true,
          completed_at: Time.zone.now
        )
      end
    end
  end
end
