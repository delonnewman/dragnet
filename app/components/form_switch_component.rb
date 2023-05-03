# frozen_string_literal: true

class FormSwitchComponent < Dragnet::Component
  attribute :id
  attribute :content

  template do
    div(class: 'form-check form-switch') do
      input(class: 'form-check-input', type: 'checkbox', role: 'switch', id: id)
      label(class: 'form-check-label', for: id) do
        content
      end
    end
  end
end
