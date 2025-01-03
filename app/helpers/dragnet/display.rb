# frozen_string_literal: true

module Dragnet
  class Display < TypeMethod
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers

    ALT_TEXT = '-'

    attribute :context
    delegate :output_buffer=, :output_buffer, :params, to: :@context, allow_nil: true
  end
end
