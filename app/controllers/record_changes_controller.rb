# frozen_string_literal: true

class RecordChangesController < ApplicationController
  def index
    record_changes = survey.record_changes.where(applied: true).order(created_at: :desc)

    respond_to do |format|
      format.atom { render :index, locals: { survey:, record_changes: } }
    end
  end

  private

  def survey
    @survey ||= Dragnet::Survey.find(params[:survey_id])
  end
end
