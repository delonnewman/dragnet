# frozen_string_literal: true

module Dragnet
  # Resumable procedures. When executed without parameters, and parameters
  # are required, an automatically generated form is presented to the user
  # to provide the parameters and once submitted the action is completed.
  #
  # Parameters can be accepted by order or by name. Higher-order Actions
  # are supported. That is actions that return actions and actions that
  # accept actions as parameters.
  class Action
    include Resumable

    def self.tag
      string = name.demodulize
      string.downcase!
      string.to_sym
    end

    attr_reader :name

    # At initialization all attributes are optional
    def initialize(**attributes)
      @name = Utils.tagged_uuid(self.class.tag)
      @attributes = attributes
    end

    # At invocation a form will be generated for any parameters that have
    # not been set. How should optional parameters be handled? Probably should
    # prompt for them also.
    #
    # If all parameters have been provided (required and optional) the action
    # will be executed.
    def invoke(params)
      initialize_parameters!(params)

      if partial?
        call_continuation
      else
        call
      end
    end

    def resume_with(params)
      invoke(params)
    end

    def partial?
      raise NoMethodError, "must be implemented by subclasses"
    end

    def call
      raise NoMethodError, "must be implemented by subclasses"
    end

    private

    attr_reader :attributes, :params

    def initialize_parameters!(params)
      @params = @attributes.merge(params)
    end

    def call_continuation
      Continuation.new(self.class.name, params)
    end
  end
end
