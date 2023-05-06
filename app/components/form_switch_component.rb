# frozen_string_literal: true

class FormSwitchComponent < Dragnet::Component
  attribute :id

  template do
    tag.div(class: 'form-check form-switch') do
      list.input(class: 'form-check-input', type: 'checkbox', role: 'switch', id: id)
      list.label(class: 'form-check-label', for: id) do
        children
      end
    end
  end
end
