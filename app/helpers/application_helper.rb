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
    info:    'circle-info',
    warning: 'triangle-exclamation',
    danger:  'circle-exclamation',
  }.freeze

  def alert_box(message: nil, level: :info)
    msg = (block_given? ? yield : message).to_s

    tag.div(class: "alert alert-#{level} alert-dismissible fade show", role: 'alert') do
      icon('fas', LEVEL_ICONS.fetch(level.to_sym)) + '&nbsp;'.html_safe +
        tag.span { msg } + tag.button(type: 'button', class: 'btn-close', 'data-bs-dismiss': 'alert', 'aria-label': 'Close')
    end
  end

  def toast(message: nil, level: :info)
    msg = (block_given? ? yield : message).to_s

    tag.div(class: "toast text-bg-#{level} border-0 fade show", role: 'alert', aria: { live: 'assertive', atomic: 'true' }) do
      tag.div(class: 'd-flex justify-content-between align-items-center me-2') do
        concat tag.div(class: 'toast-body') {
          icon('fas', LEVEL_ICONS.fetch(level.to_sym)) + '&nbsp;'.html_safe + tag.span { msg }
        }
        concat tag.button(type: 'button', class: 'btn-close', 'data-bs-dismiss': 'toast', 'aria-label': 'Close')
      end
    end
  end

  # @param [String] path
  def echo_link_to(path, **html_options, &block)
    link_to(path, path, html_options, &block)
  end

  # Return the session's authenticity token
  #
  # @return [String]
  def authenticity_token
    session[:_csrf_token]
  end

  def release_link
    release = Dragnet.release
    url     = Dragnet.github_url.join("/releases/tag/#{release}")

    link_to release, url, class: 'text-muted'
  end

  def version_link
    version = Dragnet.version
    git_sha = Dragnet.current_git_sha
    url     = Dragnet.github_url.join("tree/#{git_sha}").to_s

    link_to version, url, class: 'text-muted'
  end

  def ui_tests_link
    link_to 'UI Tests', '/js/test/index.html', class: 'text-muted', target: '_blank', rel: 'noopener'
  end

  def github_link
    icon_link Dragnet.github_url.to_s, icon: 'github', icon_type: 'fab', class: 'text-muted fa-xl'
  end

  def licence_link(label:)
    url = Dragnet.github_url.join('blob/main/LICENCE.txt').to_s

    link_to label, url, class: 'text-muted'
  end

  def author_link(label:)
    link_to label, 'https://delonnewman.name', class: 'text-muted'
  end
end
