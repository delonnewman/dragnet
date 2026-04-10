module Dragnet
  class Enum
    def self.encode_key(key)
      case key
      when Symbol
        key
      else
        key.to_s.downcase.to_sym
      end
    end

    attr_reader :value, :key
    def initialize(value, key)
      @value = value
      @key = key
    end

    def name
      self.class.name.split('::').last
    end

    def to_sym
      key.to_sym
    end

    def to_i
      value.to_i
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

    def self.inherited(base)
      base.extend(ClassMethods)
      base.extend(ActiveRecordType)
    end

    module ClassMethods
      def member(name, value: name.to_s, key: Enum.encode_key(name.to_s), &block)
        subclass = Class.new(self, &block)
        self.const_set(name, subclass)
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
        valstr = values.map(&:inspect).join(', ')
        keystr = keys.map(&:inspect).join(', ')

        raise TypeError, "#{value.inspect} can't be coerced into a #{self} member, " \
                         "valid keys are: #{keystr}, valid values are: #{valstr}"
      end

      def value?(value)
        by_value.key?(value)
      end
  
      def key?(key)
        by_key.key?(Enum.encode_key(key))
      end
  
      def of(value)
        by_value.fetch(value) do
          valstr = values.map(&:inspect).join(', ')
          raise TypeError, "#{value.inspect} is not a valid #{self} value, valid values are: #{valstr}"
        end
      end
  
      def keyed(key)
        encoded = Enum.encode_key(key)
        by_key.fetch(encoded) do
          keystr = keys.map(&:inspect).join(', ')
          raise TypeError, "#{key.inspect} is not a valid #{self} key, valid keys are: #{keystr}"
        end
      end
  
      def members
        by_key.values
      end

      def by_key
        @members ||= {}
      end

      def by_value
        @members_by_value ||= {}
      end

      def keys
        by_key.keys
      end

      def values
        by_value.keys
      end
    end

    module ActiveRecordType
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

      def changed_in_place?(raw_old_value, new_value)
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
end

=begin

class EditingStatus < Enum
  member :Published, value: 0 do
    def color_class = 'bg-success'
  end

  member :Unpublished, value: 1 do
    def color_class = 'bg-warning'
  end

  member :CannotPublish, value: -1 do
    def color_class = 'bg-danger'
  end
end

=end
