# frozen_string_literal: true

module HTMXHelper
  include Dragnet
  include ActionView::Helpers::UrlHelper

  # TODO: add link_to UJS API support
  HTMX_ONLY_ATTRS = %i[get post delete put trigger swap target].freeze
  PASS_THROUGH_ATTRS = (HTMX_ONLY_ATTRS + %i[confirm]).freeze

  alias orig_button_to button_to

  def button_to(name = nil, options = nil, html_options = EMPTY_HASH, &block)
    htmx_attr_keys = options.is_a?(Hash) ? HTMX_ONLY_ATTRS & options.keys : EMPTY_ARRAY
    return orig_button_to(name, options, html_options, &block) if htmx_attr_keys.empty?

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
