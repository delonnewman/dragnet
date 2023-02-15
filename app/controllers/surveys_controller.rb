class SurveysController < ApplicationController
  include Authenticated

  def show
    survey = DataGridPresenter.new(Survey.find(params[:id]), params)

    render :show, locals: { survey: survey }
  end

  def new
    survey = Survey.create!(author: User.first)

    redirect_to edit_survey_path(survey)
  end

  def preview
    survey = Survey.find(params[:survey_id])

    render :preview, locals: { survey: survey }
  end

  def results
    render :results, layout: 'survey', locals: { survey: Survey.find(params[:survey_id]) }
  end

  def edit
    render :edit, layout: 'survey', locals: { survey: Survey.find(params[:id]) }
  end

  def copy
    copy = Survey.find(params[:survey_id]).copy!
    # TODO: add error handling

    render partial: 'workspace/survey_card', locals: { survey: copy }
  end

  def destroy
    Survey.find(params[:id]).delete

    render html: ""
  end
end
