module Dragnet
  class Generator
    class << self
      def parameterized?
        false
      end

      def generate(*args)
        new.generate(*args)
      end
    end

    def generate(*args)
      call(*args)
    end
  end
end
