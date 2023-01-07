# frozen_string_literal: true

module Dragnet
  # Compose instances of the named class into the current class.
  #
  # @example
  #   # app/model/survey.rb
  #   class Survey < ApplicationModel
  #     extend Dragnet::Advising
  #
  #     # will create an instance method named "editing"
  #     with Survey::Editing, delegating: %i[edited? new_edit current_edit latest_edit]
  #   end
  #
  #   # app/model/survey/editing.rb
  #   class Survey::Editing < Dragnet::Advice
  #     advises Survey
  #
  #     def edited? ... end
  #     def new_edit ... end
  #     def current_edit ... end
  #     def latest_edit ... end
  #   end
  module Advising
    # Return the default method name for the class.
    #
    # @param klass [Class]
    #
    # @return [Symbol]
    def advising_class_method_name(klass)
      raise "can't generate method name for anonymous class" unless klass.name

      klass.name.split('::').last.underscore.to_sym
    end

    # @param method_name [Symbol]
    # @param klass [Class]
    # @param args [Array]
    # @param calling [Symbol, nil] (optionally) a named method that will be called after the object is instantiated
    # @param memoize [Boolean] memoize the composed object, defaults to true
    def define_advising_method(method_name, klass, args = EMPTY_ARRAY, calling: nil, memoize: true)
      define_method(method_name) do
        obj = advising_object_memos.fetch(method_name) do
          klass.new(self, *args).tap do |obj|
            advising_object_memos[method_name] = obj if memoize
          end
        end

        calling ? obj.public_send(calling) : obj
      end

      define_advising_object_memos if memoize
      method_name
    end

    def define_advising_object_memos
      return if method_defined?(:advising_object_memos)

      define_method(:advising_object_memos) do
        @advising_object_memos ||= {}
      end
    end

    # A macro method for declaring how to compose the named class.
    #
    # @param klass [Class]
    # @param args optionally pass arguments to the constructor
    # @param as [Symbol, nil] the name of the generated method, if nil will use the default name
    # @param delegating [Array<Symbol>] a list of methods to delegate to the generated method
    def advised_by(klass, *args, as: nil, delegating: EMPTY_ARRAY, **options)
      meth = as || advising_class_method_name(klass)

      define_advising_method(meth, klass, args, **options.slice(:calling, :memoize))

      delegate(*delegating, to: meth) unless delegating.empty?
    end
    alias with advised_by
  end
end
