# frozen_string_literal: true

# Helpers used throughout the application
module ApplicationHelper
  # Return Simple CSS-based Sparklines
  #
  # @param [Hash{String => Integer}] data
  # @param [Integer] width
  # @param [Integer] height
  #
  # @return [String] HTML
  def sparklines(data, width: 100, height: 50, max_value: 10)
    tag.figure(class: 'sparkline', style: "height: #{height}px") do
      data.map do |key, value|
        tag.span(class: 'index', title: key) do
          tag.span(class: 'count', style: "height: #{(value.to_f / max_value) * 100}%") { "#{value}," }
        end
      end.join.html_safe
    end
  end

  LEVEL_ICONS = {
    info:   'circle-info',
    warn:   'triangle-exclamation',
    danger: 'circle-exclamation',
  }.freeze

  def alert_box(message: nil, level: :info)
    msg = (block_given? ? yield : message).to_s
    tag.div(class: "alert alert-#{level} alert-dismissible fade show", role: 'alert') do
      icon('fas', LEVEL_ICONS.fetch(level.to_sym)) + '&nbsp;'.html_safe +
        tag.span { msg } + tag.button(type: 'button', class: 'btn-close', 'data-bs-dismiss': 'alert', 'aria-label': 'Close')
    end
  end

  # Return the session's authenticity token
  #
  # @return [String]
  def authenticity_token
    session[:_csrf_token]
  end
end
