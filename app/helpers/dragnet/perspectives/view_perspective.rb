# frozen_string_literal: true

module Dragnet
  module Perspectives
    # @abstract
    # An abstract class for perspectives that are a part of the view layer.
    class ViewPerspective < Base
      include ActionView::Helpers::TagHelper
      include Rails.application.routes.url_helpers

      attr_accessor :context

      delegate :output_buffer=, :output_buffer, :params, to: :@context, allow_nil: true

      # @param [QuestionType, Symbol] type
      # @param [ActionView::Base] context
      #
      # @return [ViewPerspective]
      def self.get(type, context)
        super(type).tap do |perspective|
          perspective.context = context
        end
      end

      def render(answers, alt: '-')
        if answers.present?
          answers.join(', ')
        else
          alt
        end
      end
    end
  end
end
