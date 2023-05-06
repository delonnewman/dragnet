# frozen_string_literal: true

class BadgeComponent < Dragnet::Component
  attribute :color, default: "info"

  template do
    tag.span(class: class_name) do
      children
    end
  end

  def class_name
    "badge bg-#{color}"
  end
end
