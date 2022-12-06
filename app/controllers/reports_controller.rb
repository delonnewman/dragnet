class ReportsController < ApplicationController
  layout 'form'

  def show
    @report = Report.new(params.slice(:name, :field_ids))
    @pagy, @responses = pagy(@report.responses)
  end
end
