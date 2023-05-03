# frozen_string_literal: true

class CardComponent < Dragnet::Component
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
    "card #{class_name}"
  end

  def footer

  end
end
