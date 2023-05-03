# frozen_string_literal: true

class IconComponent < Dragnet::Component
  attribute :name, required: true
  attribute :type, default: 'far'
  attribute :class_name

  template do
    i(class: class_names)
  end

  def class_names
    "#{type} fa-#{name} #{class_name}"
  end
end
