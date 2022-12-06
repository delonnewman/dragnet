class StatsController < ApplicationController
  layout 'form'
  
  def show
    @report = StatsReport.new(reportable)
  end

  private

  def reportable
    form_id, name, field_ids = params.values_at(:form_id, :name, :field_ids)

    return form_reportable if form_id
    return Report.new(params.slice(:name, :field_ids)) if name && field_ids

    raise 'a form_id, or name & field_ids are required'
  end

  def form_reportable
    Form
      .includes(:items, :responses, fields: %i[field_type field_options])
      .find_by_short_id!(params[:form_id])
  end
end
