# frozen_string_literal: true

class SurveyStatusIndicatorComponent < Dragnet::Component
  include WorkspaceHelper

  attribute :survey, required: true
  attribute :size, default: 7
  attribute :include_label, default: false

  template do
    div(class: 'd-flex justify-content-between align-items-center') do
      div(class: class_list, title: description, style: styles) +
        label_text
    end
  end

  def class_list
    %W[#{bg_color} d-inline-block me-1]
  end

  def styles
    { width: size, height: size, border_radius: '50%' }
  end

  def label_text
    return EMPTY_STRING unless include_label

    tag.small(class: 'text-muted') do
      description
    end
  end

  def description
    survey_status_description(survey)
  end

  def bg_color
    survey_status_bg_color(survey)
  end
end
