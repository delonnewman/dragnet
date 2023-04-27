# frozen_string_literal: true

class Button < Dragnet::Component
  html do
    button(class: 'btn btn-primary') do
      attributes[:text]
    end
  end
end
