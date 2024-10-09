# frozen_string_literal: true

class WorkspaceController < ApplicationController
  include Authenticated

  def index
    overview = Dragnet::OverviewPresenter.new(current_user.workspace)

    render :index, locals: { overview: }
  end

  def surveys
    listing = Dragnet::SurveyListingPresenter.new(current_user.workspace, params)

    render :surveys, locals: { listing: }
  end
end
