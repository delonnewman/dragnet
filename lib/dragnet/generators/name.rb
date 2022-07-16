module Dragnet
  module Generators
    class Name < Dragnet::Generator
      def call
        Faker::Name.name
      end
    end
  end
end
