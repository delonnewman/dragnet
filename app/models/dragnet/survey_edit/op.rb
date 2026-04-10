module Dragnet
  # The survey edit operations that can be performed
  class SurveyEdit::Op < Enum
    member :Add, value: 0
    member :Remove, value: 1
  end
end
