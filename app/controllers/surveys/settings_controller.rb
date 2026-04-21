class Surveys::SettingsController < SurveysController
  def show
    render :settings, locals: { survey: }
  end
end
