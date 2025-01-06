module Dragnet
  class Type
    def self.tags
      return @tags if defined?(@tags)

      array = []
      klass = self
      until klass == Dragnet::Type
        array << klass.name.demodulize.underscore.to_sym
        klass = klass.superclass
      end

      @tags = array
    end

    def self.perform(action, class_name: nil)
      klass = (class_name || name.to_s.classify).constantize
      define_method action do |**args|
        klass.new(question, **args)
      end
    end

    def self.ignore(*action_names)
      action_names.each do |name|
        define_method name do |**_|
          DoNothing.new
        end
      end
    end

    attr_reader :question
    delegate :meta, :meta=, to: :question
    delegate :tags, to: 'self.class'

    def initialize(question)
      @question = question
    end

    def send_action(action_name, ...)
      public_send(action_name, ...).send_type(self)
    end
  end
end
