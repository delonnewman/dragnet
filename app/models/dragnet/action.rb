class Dragnet
  class Action
    def self.build(name, **args)
      actions.fetch(name).new(**args)
    end

    def self.actions
      @actions ||= {}
    end

    def self.inherited(subclass)
      name = subclass.name.split("::").last.underscore.to_sym
      key  = subclass.superclass != Action ? subclass.superclass : name # TODO: make this recursive
      actions[key] = subclass
      private define_method name do |**kwargs|
        subclass.new(**kwargs)
      end
    end

    def send_type(question_type)
      public_send(question_type.ident)
    end
  end
end
