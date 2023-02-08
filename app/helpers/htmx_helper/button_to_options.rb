# frozen_string_literal: true

module HTMXHelper
  class ButtonToOptions
    attr_reader :html_options, :htmx_options

    def initialize(path, html_options)
      @html_options = html_options
      @htmx_options = _htmx_options(path)
    end

    private

    HTMX_KEY_MAPPING = [
      [:params, :vals],
      [:confirm],
      [:target],
      [:trigger, nil, 'click'],
      [:swap, nil, 'outerHTML'],
    ]
    private_constant :HTMX_KEY_MAPPING

    def _htmx_options(path)
      opts = {}
      opts.merge!(html_options.delete(:method) || :post => path) if path

      HTMX_KEY_MAPPING.each_with_object(opts) do |(name, rename, default), h|
        h[rename || name] = html_options.delete(name) || default if html_options.key?(name) || default
      end
    end
  end
end
