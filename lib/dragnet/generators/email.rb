# frozen_string_literal: true

module Dragnet
  module Generators
    # Generate random email addresses in the format: "login@domain".
    # The domain will be "example.com" by default.  If a "name" attribute
    # is given that will be used to generate a login if a "login" attribute
    # is given this will be used in the email as is.
    class Email < Dragnet::ParameterizedGenerator
      attr_reader :domain

      def initialize(name: nil, login: nil, domain: 'example.com')
        super()

        @domain = domain.generate
        @name   = name.generate
        @login  = login.generate
      end

      def name
        @name || Name.generate
      end

      def login
        @login || Dragnet::Utils.slug(name)
      end

      def call
        "#{login}@#{domain}"
      end

      alias to_s call
      alias inspect call
    end
  end
end
