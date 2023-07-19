# frozen_string_literal: true

class WorkspaceController < ApplicationController
  include Authenticated

  def index
    overview = OverviewPresenter.new(current_user.workspace)

    render :index, locals: { overview: overview }
  end

  def surveys
    listing = SurveyListingPresenter.new(current_user.workspace, params)

    render :surveys, locals: { listing: listing }
  end

end
