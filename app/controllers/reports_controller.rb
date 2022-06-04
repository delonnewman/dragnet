class ReportsController < ApplicationController
  def show
    @report = Report.new(params.slice(:question_ids, :name))
    @pagy, @replies = pagy(@report.replies)
  end
end
