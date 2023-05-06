# frozen_string_literal: true

class ApplicationComponent < Dragnet::Component
  include Dragnet
  include Rails.application.routes.url_helpers
end
