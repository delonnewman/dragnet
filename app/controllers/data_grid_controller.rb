# frozen_string_literal: true

class DataGridController < ApplicationController
  layout 'survey'

  def show
    respond_to do |format|
      format.html do
        grid = DataGridPresenter.new(Survey.find(params[:survey_id]), params)
        render :show, locals: { survey: grid }
      end
    end
  end
end
