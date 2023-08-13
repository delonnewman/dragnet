# frozen_string_literal: true

module Dragnet
  module Generators
    class LongAnswer < Dragnet::Generator
      def call(*)
        Faker::Movies::PrincessBride.quote
      end
    end
  end
end
