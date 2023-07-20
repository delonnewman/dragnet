# frozen_string_literal: true

module Dragnet
  module Generators
    class Request < Generator
      def call
        env = Rack::MockRequest.env_for('/')
        env['HTTP_USER_AGENT'] = Faker::Internet.user_agent

        ActionDispatch::Request.new(env)
      end
    end
  end
end
