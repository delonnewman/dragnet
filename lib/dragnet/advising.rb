# frozen_string_literal: true

require_relative 'advising/point_cut'

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
    def advice
      @advice ||= {}
    end

    def add_point_cut(point_cut)
      meth = point_cut.method_name
      define_advising_method(meth, point_cut.advice, point_cut.args, **point_cut.options.slice(:calling, :memoize))

      delegate(*point_cut.delegate_methods, to: meth) unless point_cut.delegate_methods.empty?
      point_cut
    end

    def remove_point_cut(point_cut)
      point_cut.delegate_methods.each do |method|
        remove_method(method)
      end
      remove_method(point_cut.method_name)
      point_cut
    end

    def remove_advice(klass)
      pc = advice.delete(klass)
      remove_point_cut(pc)
    end

    def remove_all_advice
      advice.each_value do |pc|
        remove_point_cut(pc)
      end
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
    # @param delegating [Symbol, Array<Symbol>] a list of methods to delegate to the generated method
    def with(klass, *args, as: nil, delegating: EMPTY_ARRAY, **options)
      delegating = [delegating] unless delegating.is_a?(Array)
      pc = PointCut.new(advice: klass, args: args, name: as, delegate_methods: delegating, options: options)
      add_point_cut(pc)
      advice[klass] = pc
    end
  end
end
