module Dragnet
  class ParameterizedGenerator
    class << self
      def parameterized?
        true
      end

      def [](*args, **kwargs)
        new(*args, **kwargs)
      end
    end

    def generate(*args, **kwargs)
      call(*args, **kwargs)
    end
  end
end
