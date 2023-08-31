# frozen_string_literal: true

module Dragnet
  class SessionsController < ApplicationController
    def new
      render :new
    end

    def create
      user_info = request.env['omniauth.auth']
      logger.info "USER INFO: #{user_info.inspect}"
      redirect_to root_path
    end
  end
end