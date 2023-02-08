# frozen_string_literal: true

module HTMXHelper
  include Dragnet

  PASS_THROUGH_ATTRS = %i[get post delete put trigger swap target confirm].freeze

  def button_to(name = nil, options = nil, html_options = EMPTY_HASH, &block)
    html_options, options = options, name if block_given?
    opts = ButtonToOptions.new(url_for(options), html_options)
    block = Proc.new { name } unless block_given?

    htmx(:button, opts.htmx_options, opts.html_options, &block)
  end

  def htmx(element = :div, htmx_options = EMPTY_HASH, html_options = EMPTY_HASH, &block)
    vals = htmx_options.delete(:vals) || EMPTY_HASH
    vals = vals.merge(authenticity_token: session[:_csrf_token]) unless htmx_options.key?(:get)

    attrs = html_options.merge('hx-vals': vals.to_json)
    PASS_THROUGH_ATTRS.each_with_object(attrs) do |attr, h|
      h[:"hx-#{attr}"] = htmx_options[attr]
    end

    content_tag(element, **attrs, &block)
  end
end
