module Dragnet
  module Types
    class Text < Countable
      ignore :do_before_saving_answer

      def countable?
        false
      end
    end
  end
end
