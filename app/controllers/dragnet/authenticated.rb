# frozen_string_literal: true

module Dragnet
  module Authenticated
    extend ActiveSupport::Concern

    included do
      protect_from_forgery with: :exception
      before_action :authenticate_user!
    end
  end
end