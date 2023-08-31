# frozen_string_literal: true

class ReportsController < ApplicationController
  include Authenticated

  def show
    @report         = Dragnet::Report.new(params.slice(:name, :question_ids))
    @pagy, @replies = pagy(@report.replies)
  end
end