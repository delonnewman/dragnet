# frozen_string_literal: true

class EditSurveyLinkComponent < ApplicationComponent
  attribute :survey, required: true
  attribute :include_label, default: false

  template do
    tag.a(href: path, class: 'btn btn-sm btn-outline-secondary me-1', title: 'Edit survey') do
      tag.icon(name: 'hammer') + label_text
    end
  end

  def label_text
    include_label ? '&nbps;Edit' : ''
  end

  def path
    edit_survey_path(survey)
  end
end
