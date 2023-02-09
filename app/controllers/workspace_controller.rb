# frozen_string_literal: true

class WorkspaceController < ApplicationController
  include Authenticated

  def index
    @surveys = current_user.surveys.order(:name)
  end
end
