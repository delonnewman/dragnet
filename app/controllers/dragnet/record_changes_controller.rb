# frozen_string_literal: true

module Dragnet
  class RecordChangesController < ApplicationController
    def index
      survey = Survey.find(params[:survey_id])
      record_changes = survey.record_changes.where(applied: true).order(created_at: :desc)

      respond_to do |format|
        format.atom { render :index, locals: { survey: survey, record_changes: record_changes } }
      end
    end
  end
end