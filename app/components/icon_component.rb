# frozen_string_literal: true

class IconComponent < Dragnet::Component
  attribute :icon
  attribute :type, default: 'far'

  template do
    i(class: class_name)
  end

  def class_name
    "#{type} fa-#{icon}"
  end
end
