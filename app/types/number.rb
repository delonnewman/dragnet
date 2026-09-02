module Dragnet
  module Types
    class Number < Countable
      def do_before_saving_answer(...) = DoNothing.new
    end
  end
end
