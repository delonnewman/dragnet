# frozen_string_literal: true

module Dragnet
  class ProtocolSignature
    # @return [String]
    attr_reader :name

    # @return [Array<MethodSignature>]
    attr_reader :signatures

    # @return [String, nil]
    attr_reader :doc

    delegate :to_sym, to: :name

    # @param [String] name
    # @param [Array<MethodSignature>] signatures
    # @param [String, nil] doc
    def initialize(name:, signatures:, doc: nil)
      @name       = name
      @signatures = signatures
      @doc        = doc
      freeze
    end

    def to_s
      "#<#{name} #{signatures.join(', ')}>"
    end
    alias inspect to_s

    def satisfies?(methods)
      meths = methods.to_set
      signatures.all? do |sig|
        meths.include?(sig.to_sym)
      end
    end

    def class_satisfies?(klass)
      satisfies?(klass.instance_methods)
    end

    def instance_satisfies?(object)
      satisfies?(object.methods)
    end
  end
end
