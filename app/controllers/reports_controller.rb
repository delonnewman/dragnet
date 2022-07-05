class ReportsController < ApplicationController
  layout 'survey'

  def show
    @report = Report.new(params.slice(:name, :question_ids))
    @pagy, @replies = pagy(@report.replies)
  end
end
