# frozen_string_literal: true

class SurveyOpenIndicatorComponent < Dragnet::Component
  attribute :survey, required: true

  template do
    div(class: 'd-flex align-items-center') do
      form_switch(id: id) do
        icon(type: 'fas', name: icon_name, class_name: 'text-muted')
      end
    end
  end

  def id
    "survey-#{survey.id}-open"
  end

  def icon_name
    survey.open? ? 'lock-open' : 'lock'
  end
end
