module Dragnet
  module Generators
    class ShortAnswer < Dragnet::Generator
      def call(*)
        Faker::Lorem.sentence
      end
    end
  end
end
