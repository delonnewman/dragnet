module Dragnet::Components
  class FormSwitch < Base
    include Dragnet

    def initialize(id:, input_attributes: EMPTY_HASH, label_attributes: EMPTY_HASH)
      @id = id
      @input_attributes = input_attributes
      @label_attributes = label_attributes
    end

    def view_template(&content)
      div(class: 'form-check form-switch') do
        input(class: 'form-check-input', type: 'checkbox', role: 'switch', id: @id, **@input_attributes)
        label(class: 'form-check-label', for: @id, **@label_attributes, &content)
      end
    end
  end
end
