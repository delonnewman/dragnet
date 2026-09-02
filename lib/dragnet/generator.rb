module Dragnet
  class Generator
    class << self
      def parameterized?
        false
      end

      def generate(*)
        new.generate(*)
      end
    end

    def generate(*)
      call(*)
    end
  end
end
