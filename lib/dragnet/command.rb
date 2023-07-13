# frozen_string_literal: true

require_relative 'command/result'

module Dragnet
  class Command < Composed
    include Invokable::Core

    delegate :fail, to: :@result

    def initialize(subject)
      super(subject)
      @result = Result.new
    end

    def run(*args, **kwargs)
      catch :dragnet_command_failure do
        call(*args, **kwargs)
        @result
      end
    end

    def call(*args, **kwargs)
      raise NotImplementedError
    end
  end
end
