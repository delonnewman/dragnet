module Dragnet
  class Type
    class << self
      def encode(value)
        value.to_s
      end

      def decode(_value)
        raise NoMethodError
      end

      def slug
        name.demodulize.underscore
      end

      def symbol
        slug.to_sym
      end
      alias to_sym symbol

      def tags
        return @tags if defined?(@tags)

        array = []
        klass = self
        until klass == Dragnet::Type
          array << klass.symbol
          klass = klass.superclass
        end

        @tags = array
      end

      def find(symbol)
        index.fetch(symbol.to_sym) do
          raise TypeError, "#{symbol.inspect} is not a valid #{self}"
        end
      end

      def index
        all.index_by(&:symbol)
      end

      def all(reference: :itself)
        types = []
        klasses = subclasses
        current = klasses.shift

        begin
          unless current.subclasses.empty?
            types.push(*current.subclasses.map(&reference).uniq)
            klasses.push(*current.subclasses)
            klasses.uniq!
          end
          current = klasses.shift
        end until klasses.empty?

        types
      end

      def hierarchy(reference: :itself)
        hash = {}
        klasses = subclasses
        current = klasses.shift

        begin
          unless current.subclasses.empty?
            hash[current.public_send(reference)] = current.subclasses.map(&reference).uniq
            klasses.push(*current.subclasses)
            klasses.uniq!
          end
          current = klasses.shift
        end until klasses.empty?

        hash
      end
    end

    attr_reader :question

    delegate :meta, :meta=, to: :question
    delegate :tags, :slug, :symbol, :decode, :encode, to: 'self.class'

    # @rbs question: Dragnet::Question
    # @rbs return: void
    def initialize(question)
      @question = question
      freeze
    end

    def dispatch(action_name, ...)
      public_send(action_name, ...).dispatch(self)
    end

    def countable?
      is_a?(Types::Countable)
    end

    # @abstract
    # @rbs _answer: Dragnet::Answer
    # @rbs return: Dragnet::Value
    def build_value_from_answer(_answer)
      raise NoMethodError, "no implemented by #{self.class}, subclasses should implement"
    end

    # @rbs reply: Dragnet::Reply
    # @rbs return: Dragnet::Value
    def build_value_from_reply(reply)
      build_value_from_answer(reply.answers.first)
    end

    # @abstract
    # @rbs answer: Dragnet::Answer
    # @rbs value: Dragnet::Value
    # @rbs return: void
    def assign_value(_answer, _value)
      raise NoMethodError, "no implemented by #{self.class}, subclasses should implement"
    end
  end
end
