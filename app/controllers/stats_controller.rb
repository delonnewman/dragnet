# frozen_string_literal: true

# TODO: move to ReportsController, remove survey support
class StatsController < ApplicationController
  include Authenticated

  layout 'survey'

  def show
    report = Dragnet::StatsReport.new(reportable)

    render :show, locals: { report:, reportable: }
  end

  private

  def reportable
    survey_id, name, question_ids = params.values_at(:survey_id, :name, :question_ids)

    return survey_reportable if survey_id
    return Dragnet::Report.new(params.slice(:name, :question_ids)) if name && question_ids

    raise 'a survey_id, or name & question_ids are required'
  end

  def survey_reportable
    Dragnet::Survey
      .includes(:answers, :replies, questions: %i[question_type question_options])
      .find_by_short_id!(params[:survey_id])
  end
end
