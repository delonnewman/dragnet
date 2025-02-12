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
      return superclass.name unless name

      string = name.demodulize
      string.downcase!
      string.to_sym
    end

    attr_reader :name

    # At initialization all attributes are optional
    def initialize(attributes = EMPTY_HASH)
      raise 'only subclasses of Action can be instantiated' if self.class == Dragnet::Action

      @name = Utils.tagged_uuid(self.class.tag)
      @attributes = attributes
    end

    # At invocation a form will be generated for any parameters that have
    # not been set. How should optional parameters be handled? Probably should
    # prompt for them also.
    #
    # If all parameters have been provided (required and optional) the action
    # will be executed.
    #
    # @see #partial?, #invoke, #resume_with
    def call(params)
      collected_params = initialize_parameters!(params)

      return invoke unless partial?

      Continuation.new(self.class.name, collected_params)
    end

    # Resume the action with the supplied parameters.
    # By default the action is just called again.
    def resume_with(params)
      call(params)
    end

    # @abstract
    # Return true if the action is partially executed, otherwise return false.
    def partial?
      raise NoMethodError, "must be implemented by subclasses"
    end

    # @abstract
    # Subclass implementation of the body of the action
    def invoke
      raise NoMethodError, "must be implemented by subclasses"
    end

    # @abstract
    # Return a formlet that can be used to collect the required information
    def formlet
      raise NoMethodError, "must be implemented by subclasses"
    end

    private

    attr_reader :attributes
    attr_accessor :params

    def initialize_parameters!(params)
      self.params = @attributes.merge(params)
    end
  end
end
