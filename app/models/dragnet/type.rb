module Dragnet
  class Type
    class << self
      def encode(value)
        value.to_s
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

      def perform(action, class_name: nil)
        klass = (class_name || name.to_s.classify).constantize
        define_method action do |**args|
          klass.new(question, **args)
        end
      end

      def ignore(*action_names)
        action_names.each do |name|
          define_method name do |**_|
            DoNothing.new
          end
        end
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
    delegate :tags, to: 'self.class'

    def initialize(question)
      @question = question
    end

    def dispatch(action_name, ...)
      public_send(action_name, ...).dispatch(self)
    end
  end
end
