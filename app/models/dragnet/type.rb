module Dragnet
  class Type
    def self.perform(*action_names)
      action_names.each do |name|
        klass = "::Dragnet::Action::#{name.to_s.classify}".constantize
        define_method name do |**args|
          klass.new(question_type, **args)
        end
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
      public_send(action_name, ...).send_type(question_type)
    end
  end
end
