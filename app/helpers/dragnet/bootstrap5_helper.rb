# frozen_string_literal: true

module Dragnet
  module Bootstrap5Helper
    def nav_link(content, path = nil, active:, **html_options)
      classes = %w[nav-link]

      unless path
        path    = content
        content = nil
      end

      if active
        classes << 'active'
        html_options[:aria] = { current: 'page' }
      end

      tag.a(class: classes, href: path, **html_options) do
        if block_given?
          yield
        else
          content
        end
      end
    end
  end
end