class Surveys::CopyController < SurveysController
  def create
    copy = survey.copy!

    redirect_to edit_survey_path(copy)
  end
end
