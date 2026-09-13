module Dragnet
  class Enum
    class Error < TypeError
      def self.member_missing(enum, value)
        val_str = enum.values.map(&:inspect).join(', ')
        key_str = enum.keys.map(&:inspect).join(', ')
        msg    = "#{value.inspect} can't be coerced into a #{enum} member, " \
                 "valid keys are: #{key_str}, valid values are: #{val_str}"

        new(msg)
      end

      def self.invalid_value(enum, value)
        val_str = enum.values.map(&:inspect).join(', ')
        msg    = "#{value.inspect} is not a valid #{enum} value, valid " \
                 "value are: #{val_str}"

        new(msg)
      end

      def self.invalid_key(enum, key)
        key_str = enum.keys.map(&:inspect).join(', ')
        msg    = "#{key.inspect} is not a valid #{enum} key, valid keys " \
                 "are: #{key_str}"

        new(msg)
      end
    end

    def self.encode_key(key)
      case key
      when Symbol
        key
      else
        key.to_s.downcase.to_sym
      end
    end

    attr_reader :value, :key

    delegate :to_sym, to: :key
    delegate :to_i, to: :value

    def initialize(value, key)
      @value = value
      @key = key
    end

    def name
      self.class.name.split('::').last
    end

    def ==(other)
      case other
      when String
        key == Enum.encode_key(other)
      when Symbol
        key == other
      else
        value == other
      end
    end

    def to_json(...)
      value.to_json(...)
    end

    # Class Methods

    class << self
      def member(name, value: name.to_s, key: Enum.encode_key(name), &block)
        subclass = Class.new(self, &block)
        const_set(name, subclass)
        instance = subclass.new(value, key)

        define_method(:"#{instance.key}?") { false }
        subclass.define_method(:"#{instance.key}?") { true }
        define_singleton_method(instance.key) { instance }

        by_key[instance.key] = instance
        by_value[value] = instance
      end

      def coerce(value)
        return value if value.is_a?(self)
        return of(value) if value?(value)
        return keyed(value) if key?(value)

        member_missing(value)
      end

      def member_missing(value)
        raise Error.member_missing(self, value)
      end

      def value?(value)
        by_value.key?(value)
      end

      def key?(key)
        by_key.key?(Enum.encode_key(key))
      end

      def of(value)
        by_value.fetch(value) do
          raise Error.invalid_value(self, value)
        end
      end

      def keyed(key)
        encoded = Enum.encode_key(key)
        by_key.fetch(encoded) do
          raise Error.invalid_key(self, key)
        end
      end

      def members
        by_key.values
      end

      def by_key
        @by_key ||= {}
      end

      def by_value
        @by_value ||= {}
      end

      def keys
        by_key.keys
      end

      def values
        by_value.keys
      end
    end

    # ActiveRecord Type

    def cast(value)
      coerce(value) unless value.nil?
    end
    alias deserialize cast

    def assert_valid_value(value)
      value.nil? || coerce(value)
    end

    def changed?(old_value, new_value, _new_value_before_type_cast)
      old_value != new_value
    end

    def changed_in_place?(_raw_old_value, _new_value)
      false
    end

    def serialize(value)
      case value
      when Enum
        value.value
      else
        value
      end
    end

    def binary?
      false
    end

    def type
      if superclass == Enum
        name.split('::').map(&:underscore).join('_').to_sym
      else
        superclass.type
      end
    end
  end
end
