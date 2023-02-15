class SurveysController < ApplicationController
  include Authenticated

  layout 'survey'

  def show
    render :show, locals: { survey: Survey.find(params[:id]) }
  end

  def new
    survey = Survey.create!(author: User.first)

    redirect_to edit_survey_path(survey)
  end

  def edit
    render :edit, locals: { survey: Survey.find(params[:id]) }
  end

  def destroy
    Survey.find(params[:id]).delete

    render html: ""
  end

  def copy
    copy = Survey.find(params[:survey_id]).copy!
    # TODO: add error handling

    render partial: 'workspace/survey_card', locals: { survey: copy }
  end

  def preview
    survey = Survey.find(params[:survey_id])

    render :preview, locals: { survey: survey }
  end

  def settings
    render :settings, locals: { survey: Survey.find(params[:survey_id]) }
  end
end
