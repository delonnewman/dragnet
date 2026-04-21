class Surveys::SharingController < SurveysController
  def show
    render :share, locals: { survey: Dragnet::SurveyPresenter.new(survey, params) }
  end
end
