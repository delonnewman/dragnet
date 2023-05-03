# frozen_string_literal: true

class SurveyCardComponent < Dragnet::Component
  include Rails.application.routes.url_helpers
  include WorkspaceHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  attribute :survey, Survey

  template do
    div(id: survey_id, class: 'survey-card card d-inline-block', style: 'width: 360px; margin: 7px') do
      div(class: 'card-body') do
        div(class: 'card-title d-flex justify-content-between align-items-center') do
          div do
            survey_link
            copy_of_link
          end
          status_indicator
        end
        div(class: 'mb-2') do
          badge(color: 'secondary') { public_indicator }
          badge(color: 'info') { records_count }
        end
      end
      div(class: 'card-footer d-flex justify-content-between align-items-center') do
        div(class: 'd-flex align-items-center') do
          edit_link
          share_dropdown
        end
        element :survey_open_indicator, survey: survey
      end
    end
  end

  def survey_name
    survey.name
  end

  def survey_id
    survey.id
  end

  def copy_of_link
    survey_copy_of_link(survey)
  end

  def survey_link
    link_to survey.name, survey_path(survey)
  end

  def status_indicator
    survey_status_indicator(survey)
  end

  def public_indicator
    survey_public_indicator(survey)
  end

  def records_count
    pluralize survey.replies.count, 'record'
  end

  def edit_link
    edit_survey_link(survey, include_label: true)
  end

  def share_dropdown
    survey_share_dropdown(survey)
  end
end
