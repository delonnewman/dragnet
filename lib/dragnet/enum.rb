module Dragnet
  class Enum
    class Member
      attr_reader :value
      def initialize(value)
        @value = value
      end

      def name
        self.class.name.split('::').last
      end
      
      def key
        name.underscore.to_sym
      end
      alias to_sym key

      def to_i
        value.to_i
      end

      def ==(other)
        case other
        when String
          key == other.downcase.underscore.to_sym
        when Symbol
          key == other.name.downcase.underscore.to_sym
        else
          value == other
        end
      end
    end

    def self.member(name, value: name.to_s, &block)
      @members ||= {}
      @members_by_value ||= {}

      subclass = Class.new(Member, &block)
      self.const_set(name, subclass)
      instance = subclass.new(value)

      define_singleton_method(instance.key) { instance }
      @members[name.to_s.downcase.underscore.to_sym] = instance
      @members_by_value[value] = instance
    end

    def self.coerce(value)
      return of(value) if value?(value)
      return keyed(value) if key?(value)

      member_missing(value)
    end

    def self.member_missing(value)
      raise TypeError, "#{value.inspect} can't be coerced into a #{self} member"
    end

    def self.value?(value)
      (@members_by_value || EMPTY_HASH).key?(value)
    end

    def self.key?(key)
      (@members || EMPTY_HASH).key?(key.to_s.downcase.underscore.to_sym)
    end

    def self.of(value)
      (@members_by_value || EMPTY_HASH).fetch(value) do
        raise TypeError, "#{value.inspect} is not a valid #{self} value"
      end
    end

    def self.keyed(key)
      (@members || EMPTY_HASH).fetch(key.to_s.downcase.underscore.to_sym) do
        raise TypeError, "#{key.inspect} is not a valid #{self} key"
      end
    end

    def self.members
      (@members || EMPTY_HASH).values
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
