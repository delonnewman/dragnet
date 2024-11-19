module Dragnet
  class Type::Date < Type
    def perform(action)
      action.date(question_type)
    end
  end
end
