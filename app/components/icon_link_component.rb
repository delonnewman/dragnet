# frozen_string_literal: true

class IconLinkComponent < Dragnet::Component
  attribute :label
  attribute :path
  attribute :icon_name
  attribute :icon_type, default: 'fas'

  template do
    tag.a(href: path) do
      tag.icon(name: icon_name, type: icon_type) + tag.nbsp + children
    end
  end
end
