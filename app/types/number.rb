module Dragnet
  module Types
    class Number < Basic
      include Countable

      def do_before_saving_answer(...) = DoNothing.new
    end
  end
end
