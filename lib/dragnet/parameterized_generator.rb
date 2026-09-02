module Dragnet
  class ParameterizedGenerator
    class << self
      def parameterized?
        true
      end

      def [](*, **)
        new(*, **)
      end
    end

    def generate(*, **)
      call(*, **)
    end
  end
end
