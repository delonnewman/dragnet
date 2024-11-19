module Dragnet
  class Type
    def self.perform(*action_names)
      action_classes = action_names.map do |name|
        [name, "Action::#{name.classify}".constantize]
      end

      action_classes.each do |(name, klass)|
        define_method name do |**args|
          klass.new(**args)
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

    def send_action(action_name, ...)
      public_send(action_name, ...).send_type(question_type)
    end
  end
end
