# frozen_string_literal: true

module Dragnet
  class Command < Composed
    require_relative 'command/result'

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

    private

    attr_reader :result
  end
end
