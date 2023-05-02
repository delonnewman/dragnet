# frozen_string_literal: true

class SurveyCardComponent < Dragnet::Component
  include Rails.application.routes.url_helpers
  include WorkspaceHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  attribute :survey, Survey

  template do
    div(id: survey_id, class: 'survey-card card d-inline-block', style: 'width: 360px; margin: 7px') {
      div(class: 'card-body') {
        div(class: 'card-title d-flex justify-content-between align-items-center') {
          div {
            survey_link
            copy_of_link
          }
          status_indicator
        }
        div(class: 'mb-2') {
          badge(color: 'secondary') { public_indicator }
          badge(color: 'info') { records_count }
        }
      }
      div(class: 'card-footer d-flex justify-content-between align-items-center') {
        div(class: 'd-flex align-items-center') {
          edit_link
          share_dropdown
        }
        open_indicator
      }
    }
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

  def open_indicator
    survey_open_indicator(survey) unless survey.public?
  end
end
