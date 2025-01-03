module Dragnet
  class Type::Number < Type::BasicCountable
    ignore :do_before_saving_answer
  end
end
