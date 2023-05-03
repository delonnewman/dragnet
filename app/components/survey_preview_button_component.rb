# frozen_string_literal: true

class SurveyPreviewButtonComponent < Dragnet::Component
  attribute :title,  required: true
  attribute :icon,   required: true
  attribute :width,  required: true
  attribute :height, required: true

  template do
    button(class: 'btn btn-secondary', data: data, script: hyperscript, title: title) do
      icon(type: 'fas', name: icon)
    end
  end

  def hyperscript
    "on click set #preview-frame.width to @data-width then set #preview.height to @data-height"
  end

  def data
    { width: width, height: height }
  end

  def title
    "#{title} #{width}x#{height}"
  end
end
