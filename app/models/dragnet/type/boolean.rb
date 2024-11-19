# frozen_string_literal: true

module Dragnet
  class Type::Boolean < Type
    def perform(action)
      action.boolean(question_type)
    end
  end
end
