# frozen_string_literal: true

module FormHelper
  def form_switch(id:, &block)
    tag.div(class: 'form-check form-switch') do
      tag.input(class: 'form-check-input', type: 'checkbox', role: 'switch', id: id) +
        tag.label(class: "form-check-label", for: id, &block)
    end
  end
end