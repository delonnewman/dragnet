# frozen_string_literal: true

module Dragnet
  class ReportsController < ApplicationController
    include Authenticated

    def show
      @report = Report.new(params.slice(:name, :question_ids))
      @pagy, @replies = pagy(@report.replies)
    end
  end
end