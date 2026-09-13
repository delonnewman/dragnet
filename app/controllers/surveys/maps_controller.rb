class Surveys::MapsController < SurveysController
  def show
    render Dragnet::Views::Surveys::Map.new(survey:)
  end
end
