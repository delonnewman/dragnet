# frozen_string_literal: true

class ShareDropdownComponent < ApplicationComponent
  attribute :survey, required: true
  attribute :align_menu_end, default: false

  let(:menu_class_name) { "dropdown-menu #{dropdown_menu_end}" }
  let(:dropdown_menu_end) { 'dropdown-menu-end' if align_menu_end }

  template do
    tag.div(class: 'dropdown me-1') do
      list.a(class: 'btn btn-sm btn-secondary dropdown-toggle', href: '#', role: 'button', data: { bs_toggle: 'dropdown' }) do
        tag.icon(type: 'fas', name: 'share') + tag.nbsp + 'Share'
      end
      list.ul(class: menu_class_name) do
        list.li(class: 'dropdown-item') { 'Copy Link' }
      end
    end
  end
end
