# frozen_string_literal: true

class SurveyCardTitleComponent < Dragnet::Component
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include WorkspaceHelper

  attribute :survey, required: true

  template do
    div(class: 'card-title d-flex justify-content-between align-items-center') do
      list << div { survey_link + copy_of_link }
      list << survey_status_indicator(survey: survey)
    end
  end

  def survey_link
    link_to survey.name, survey_path(survey)
  end

  def copy_of_link
    survey_copy_of_link(survey)
  end
end
