# frozen_string_literal: true

module Dragnet
  module Triggers
    class AsynchronousTrigger < Base
      include Concurrent::Async

      def call
        execution.update!(status: :pending)
        async.execute.add_observer do |timestamp, value, reason|
          if reason
            execution.update!(update(timestamp, status: :failure, output: reason))
          else
            execution.update!(update(timestamp, status: :success, output: value))
          end
        end
      end

      private

      def update(timestamp, **other)
        { completed: true, completed_at: timestamp }.merge(other)
      end
    end
  end
end
