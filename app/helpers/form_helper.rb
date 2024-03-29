# frozen_string_literal: true

module FormHelper
  include Dragnet

  def form_switch(id:, input_attributes: EMPTY_HASH, label_attributes: EMPTY_HASH, &block)
    tag.div(class: 'form-check form-switch') do
      tag.input(class: 'form-check-input', type: 'checkbox', role: 'switch', id: id, **input_attributes) +
        tag.label(class: 'form-check-label', for: id, **label_attributes, &block)
    end
  end
end