module Dragnet
  class MethodSignature
    # @return [String]
    attr_reader :name

    # @return [Integer]
    attr_reader :arity

    # @return [String, nil]
    attr_reader :doc

    delegate :to_sym, to: :name

    # @param [String] name
    # @param [Integer] arity
    # @param [String, nil] doc
    def initialize(name:, arity:, doc: nil)
      @name  = name
      @arity = arity
      @doc   = doc
      freeze
    end

    def doc?
      !doc.nil?
    end

    def to_s
      "#{name}/#{arity}"
    end

    alias inspect to_s
  end
end
