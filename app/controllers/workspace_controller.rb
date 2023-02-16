# frozen_string_literal: true

class WorkspaceController < ApplicationController
  include Authenticated
  include Bumpspark::Helper

  def index
    overview = OverviewPresenter.new(current_user)

    render :index, locals: { overview: overview }
  end

  def surveys
    listing = SurveyListingPresenter.new(current_user, params)

    render :surveys, locals: { listing: listing }
  end
end
