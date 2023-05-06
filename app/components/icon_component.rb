# frozen_string_literal: true

class IconComponent < Dragnet::Component
  attribute :name, required: true
  attribute :type, default: 'far'

  let(:class_list) do
    %W[#{type} fa-#{name} #{attributes[:class]}]
  end

  template do
    tag.i(class: class_list)
  end
end
