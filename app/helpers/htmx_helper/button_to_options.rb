# frozen_string_literal: true

module HTMXHelper
  # rubocop: disable Rails/HelperInstanceVariable
  class ButtonToOptions
    attr_reader :html_options, :htmx_options

    def initialize(path, html_options)
      @html_options = html_options
      @htmx_options = _htmx_options(path)
    end

    private

    HTMX_KEY_MAPPING = [
      %i[params vals],
      [:confirm],
      [:target],
      [:trigger, nil, 'click'],
      [:swap, nil, 'outerHTML'],
    ].freeze
    private_constant :HTMX_KEY_MAPPING

    # rubocop: disable Metrics/CyclomaticComplexity
    def _htmx_options(path)
      opts                                        = {}
      opts[html_options.delete(:method) || :post] = path if path

      HTMX_KEY_MAPPING.each_with_object(opts) do |(name, rename, default), h|
        h[rename || name] = html_options.delete(name) || default if html_options.key?(name) || default
      end
    end

    # rubocop: enable Metrics/CyclomaticComplexity
  end

  # rubocop: enable Rails/HelperInstanceVariable
end