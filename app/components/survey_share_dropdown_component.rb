# frozen_string_literal: true

class SurveyShareDropdownComponent < Dragnet::Component
  attribute :survey, required: true
  attribute :align_menu_end, default: false

  template do
    div(class: 'dropdown me-1') do
      a(class: 'btn btn-sm btn-secondary dropdown-toggle', href: '#', role: 'button', data: { bs_toggle: 'dropdown' }) do
        icon(type: 'fas', name: 'share')
        nbsp
        text { 'Share' }
      end
      ul(class: menu_class_name) do
        li(class: 'dropdown-item') { 'Copy Link' }
      end
    end
  end

  def menu_class_name
    "dropdown-menu #{dropdown_menu_end}"
  end

  def dropdown_menu_end
    'dropdown-menu-end' if align_menu_end
  end
end
