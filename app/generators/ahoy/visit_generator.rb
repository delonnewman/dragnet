# frozen_string_literal: true

module Ahoy
  class VisitGenerator < Dragnet::ActiveRecordGenerator
    def call(*)
      Visit.new(visit_properties) do |v|
        v.started_at    = attributes.fetch(:started_at) { Faker::Date.between(from: 2.years.ago, to: Date.today) }
        v.user          = attributes.fetch(:user) { Faker::Boolean.boolean ? User.generate : nil }
        v.user_agent    = Faker::Internet.user_agent
        v.visit_token   = random_token
        v.visitor_token = random_token
      end
    end

    private

    def visit_properties
      Ahoy::VisitProperties.new(Request.generate, api: false).generate.compact_blank
    end

    def random_token
      SecureRandom.uuid
    end
  end
end
