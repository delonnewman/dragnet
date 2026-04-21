class Surveys::AccessController < SurveysController
  def open
    survey.open!

    render partial: 'workspace/survey_card', locals: { survey: }
  end

  def close
    survey.close!

    render partial: 'workspace/survey_card', locals: { survey: }
  end
end
