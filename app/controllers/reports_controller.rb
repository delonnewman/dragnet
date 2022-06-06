class ReportsController < ApplicationController
  def show
    @report = Report.new(params.assert_keys(:name, :question_ids))
    @pagy, @replies = pagy(@report.replies)
  end
end
