# frozen_string_literal: true

class BtnComponent < Dragnet::Component
  attribute :disabled, :boolean
  attribute :kind, default: 'primary'
  attribute :onclick, default: ""
  attribute :content

  template do
    button(class: class_name, disabled: disabled, onclick: onclick) {
      content
    }
  end

  def class_name
    "btn btn-#{kind}"
  end
end
