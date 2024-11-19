class Dragnet
  class Type
    # Dispatch extensible actions by type
    def perform(action, **args)
      Action.build(action, **args).send_type(question_type)
    end

    def assign_value(...)
      Action::AssignValue.new(...)
    end

    def get_value(...)
      Action::GetValue.new(...)
    end
  end
end
