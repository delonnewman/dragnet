class Dragnet
  class Action
    def send_type(question_type)
      public_send(question_type.ident)
    end
  end
end
