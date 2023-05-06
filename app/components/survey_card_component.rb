# frozen_string_literal: true

class SurveyCardComponent < ApplicationComponent
  attribute :survey, required: true
  attribute :user, required: true

  let(:survey_id) { survey.id }
  let(:survey_name) { survey.name }

  let(:records_count) do
    n     = survey.replies.count
    label = n == 1 ? 'record' : 'records'
    "#{n} #{label}"
  end

  let(:label_content) do
    tag.div do
      list.a(survey.name, href: survey_path(survey))
      list.copy_of_link(survey: survey, user: user) if survey.copy?
    end
  end

  template do
    tag.div(id: survey_id, class: %w[survey-card card d-inline-block], style: { width: 360, margin: 7 }) do
      list.div(class: 'card-body') do
        list.div(class: 'card-title d-flex justify-content-between align-items-center') do
          label_content +
            tag.status_indicator(survey: survey)
        end
        list.div(class: 'mb-2') do
          list.badge(color: 'secondary') { tag.public_indicator(survey: survey) }
          list.badge(color: 'info') { records_count }
        end
      end
      list.div(class: 'card-footer d-flex justify-content-between align-items-center') do
        list.div(class: 'd-flex align-items-center') do
          list.edit_survey_link(survey: survey, include_label: true)
          list.share_dropdown(survey: survey)
        end
        list.open_indicator(survey: survey)
      end
    end
  end
end
