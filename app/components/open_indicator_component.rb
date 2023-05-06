# frozen_string_literal: true

class OpenIndicatorComponent < ApplicationComponent
  attribute :survey, required: true

  let(:id) { "survey-#{survey.id}-open" }
  let(:icon_name) { survey.open? ? 'lock-open' : 'lock' }

  template do
    tag.div(class: 'd-flex align-items-center') do
      tag.form_switch(id: id) do
        tag.icon(type: 'fas', name: icon_name, class_name: 'text-muted')
      end
    end
  end
end
