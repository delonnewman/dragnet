# frozen_string_literal: true

require_relative 'protocol/method_signature'
require_relative 'protocol/protocol_signature'

module Dragnet
  class Protocol
    class UnsatisfiedError < StandardError; end

    def self.inherited(subclass)
      Object.define_method(subclass.name) do
        subclass.define_module
      end
    end

    class << self
      def signature
        @signature ||= ProtocolSignature.new(name: name, signatures: method_signatures)
      end

      def method_signatures
        @method_signatures ||= instance_methods(false).map do
          MethodSignature.new(name: _1.name, arity: instance_method(_1).arity)
        end
      end

      def define_module
        mod = self.module
        Object.const_set(module_name, mod) unless module_defined?
        mod
      end

      def module_defined?
        Object.const_defined?(module_name)
      end

      def module_name
        @module_name ||= signature.name.classify.sub('Protocol', '')
      end

      def module
        return @module if @module

        @module = Module.new
        class << @module
          attr_reader :protocol
        end
        @module.instance_variable_set(:@protocol, signature)

        @module.module_eval <<~RUBY, __FILE__, __LINE__ + 1
          def self.included(base)
            unless protocol.class_satisfies?(base)
              raise UnsatisfiedError, "protocol `\#{protocol}` is not satisfied by \#{base}"
            end
          end
        RUBY

        @module
      end
    end
  end
end
