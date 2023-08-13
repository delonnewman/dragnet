module Dragnet
  module Generators
    class ShortAnswer < Dragnet::Generator
      def call(*)
        Faker::Quote.yoda
      end
    end
  end
end
