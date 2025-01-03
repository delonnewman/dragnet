module Dragnet
  class Type::Choice < Type::BasicCountable
    ignore :do_before_saving_answer
  end
end
