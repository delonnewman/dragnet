# frozen_string_literal: true

module UrlHelper
  def icon_link(label, path, icon:, icon_type: 'fas', **html_options)
    link_to path, **html_options do
      icon(icon_type, icon) + '&nbsp;'.html_safe + label
    end
  end

  def icon_button(label, path = nil, icon:, icon_type: 'fas', method: :post, **html_options)
    unless path
      path  = label
      label = nil
    end

    button_to path, method: method, **html_options do
      if label
        icon(icon_type, icon) + '&nbsp;'.html_safe + label
      else
        icon(icon_type, icon)
      end
    end
  end
end
