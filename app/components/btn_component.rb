# frozen_string_literal: true

class BtnComponent < Dragnet::Component
  attribute :disabled, :boolean
  attribute :kind, default: 'primary'
  attribute :onclick

  template do
    tag.button(class: class_name, disabled: disabled, onclick: onclick) do
      children
    end
  end

  def class_name
    "btn btn-#{kind}"
  end
end
