# frozen_string_literal: true

class BadgeComponent < Dragnet::Component
  attribute :color, default: "info"
  attribute :content

  template do
    span(class: class_name) do
      content
    end
  end

  def class_name
    "badge bg-#{color}"
  end
end
