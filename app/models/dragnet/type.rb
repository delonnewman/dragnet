module Dragnet
  class Type
    def self.perform(action, class_name: nil)
      klass = class_name || name.to_s.classify.constantize
      define_method name do |**args|
        klass.new(question_type, **args)
      end
    end

    def self.ignore(*action_names)
      action_names.each do |name|
        define_method name do |**_|
          Action::DoNothing.new
        end
      end
    end

    attr_reader :question_type

    def initialize(question_type)
      @question_type = question_type
    end

    def send_action(action_name, ...)
      public_send(action_name, ...).send_type(self)
    end

    def tags
      return @tags if defined?(@tags)

      array = [question_type.ident, self.class.name.demodulize.underscore.to_sym]
      array << self.class.superclass.name.demodulize.underscore.to_sym unless self.class.superclass == Dragnet::Type
      array.uniq!

      @tags = array
    end
  end
end
