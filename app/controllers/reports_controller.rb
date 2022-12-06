class ReportsController < ApplicationController
  layout 'form'

  def show
    @report = Report.new(params.slice(:name, :field_ids))
    @pagy, @replies = pagy(@report.responses)
  end
end
