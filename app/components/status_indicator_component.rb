# frozen_string_literal: true

class StatusIndicatorComponent < ApplicationComponent
  include WorkspaceHelper

  attribute :survey, required: true
  attribute :size, default: 7
  attribute :include_label, default: false

  let(:class_list) { %W[#{bg_color} d-inline-block me-1] }
  let(:styles) { { width: size, height: size, border_radius: '50%' } }

  let(:label_text) do
    return '' unless include_label

    tag.small(class: 'text-muted') do
      description
    end
  end

  let(:description) { survey_status_description(survey) }
  let(:bg_color) { survey_status_bg_color(survey) }

  template do
    tag.div(class: 'd-flex justify-content-between align-items-center') do
      tag.div(class: class_list, title: description, style: styles) +
        label_text
    end
  end
end
