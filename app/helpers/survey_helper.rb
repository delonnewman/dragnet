# frozen_string_literal: true

module SurveyHelper
  def survey_share_code(survey)
    %(<div id="survey-form"></div><script src="#{new_reply_url(survey, format: 'js')}"></script>)
  end
end
