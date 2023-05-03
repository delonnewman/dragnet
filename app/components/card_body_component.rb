# frozen_string_literal: true

class CardBodyComponent < Dragnet::Component
  attribute :id
  attribute :class_name
  attribute :style
  attribute :content

  template do
    div(id: id, class: classes, style: style) do
      content
    end
  end

  def classes
    "card-body #{class_name}"
  end
end
