module ApplicationHelper
  def javascripts
    @javascripts ||= []
  end

  def sparklines(data, width: 100, height: 50)
    id = "sparkline-#{data.hash}"
    javascripts << "sparkline(document.querySelector('##{id}'), #{data.to_json})".html_safe
    tag.svg(class: 'sparkline', id: id, width: width, height: height, 'stroke-width': 3)
  end

  LEVEL_ICONS = {
    info: 'circle-info',
    warn: 'triangle-exclamation',
    danger: 'circle-exclamation',
  }.freeze

  def alert_box(message: nil, level: :info, &block)
    msg = (block_given? ? block.call : message).to_s
    tag.div(class: "alert alert-#{level} alert-dismissible fade show", role: "alert") do
      icon('fas', LEVEL_ICONS.fetch(level.to_sym)) + '&nbsp;'.html_safe +
        tag.span { msg } +
          tag.button(type: "button", class: "btn-close", 'data-bs-dismiss': "alert", 'aria-label': "Close")
    end
  end
end
