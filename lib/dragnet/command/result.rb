# frozen_string_literal: true

module Dragnet
  class Command::Result
    attr_reader :error

    def initialize
      @failure = false
      @stash = {}
    end

    def finalize!
      freeze
      @stash.freeze
      @error.freeze
      self
    end

    def failure!(message)
      @error = message
      @failure = true
    end

    def failure?
      @failure
    end

    def success?
      !failure?
    end

    def fail!(error:)
      failure!(error)
      finalize!
      throw :dragnet_command_failure
    end

    private

    def method_missing(method_name, *args)
      if method_name.name.end_with?('=')
        raise ArgumentError, "wrong number of arguments expected 1, got #{args.length}" unless args.length == 1

        @stash[method_name.name.chop.to_sym] = args.first
        return
      end

      raise ArgumentError, "wrong number of arguments expected 0, got #{args.length}" unless args.empty?

      if method_name.name.end_with?('?')
        !!@stash[method_name]
      else
        super unless @stash.key?(method_name)

        @stash[method_name]
      end
    end

    def respond_to_missing?(method_name)
      name = method_name.name
      return true if name.end_with?('=', '?')

      @stash.key?(method_name)
    end
  end
end
