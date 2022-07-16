# frozen_string_literal: true

module Dragnet
  # Compose instances of the named class into the current class.
  #
  # @example
  #   # app/model/survey.rb
  #   class Survey < ApplicationModel
  #     extend Dragnet::Composing
  #
  #     # will create an instance method named "editing"
  #     composes Survey::Editing, delegating: %i[edited? new_edit current_edit latest_edit]
  #   end
  #
  #   # app/model/survey/editing.rb
  #   class Survey::Editing
  #     def initialize(survey)
  #       @survey = survey
  #     end
  #
  #     def edited? ... end
  #     def new_edit ... end
  #     def current_edit ... end
  #     def latest_edit ... end
  #   end
  module Composing
    # Return the default method name for the class.
    #
    # @param klass [Class]
    #
    # @return [Symbol]
    def composed_class_default_method_name(klass)
      klass.name.split('::').last.underscore.to_sym
    end

    # A macro method for declaring how to compose the named class.
    #
    # @param klass [Class]
    # @param args optionally pass arguments to the constructor
    # @param as [Symbol, nil] the name of the generated method, if nil will use the default name
    # @param delegating [Array<Symbol>] a list of methods to delegate to the generated method
    # @param calling [Symbol] (optionally) a named method that will be called after the object is instantiated
    def composes(klass, *args, as: nil, delegating: EMPTY_ARRAY, calling: nil)
      meth = as || composed_class_default_method_name(klass)

      define_method(meth) do
        obj = klass.new(self, *args)
        calling ? obj.public_send(calling) : obj
      end

      delegate(*delegating, to: meth) unless delegating.empty?
    end
  end
end