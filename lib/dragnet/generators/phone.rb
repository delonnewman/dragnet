module Dragnet
  module Generators
    class Phone < Dragnet::Generator
      def call
        "(#{three}) #{three}-#{four}"
      end

      private

      def three
        format "%03d", rand(999)
      end

      def four
        format "%04d", rand(9999)
      end
    end
  end
end
