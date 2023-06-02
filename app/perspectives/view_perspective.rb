# frozen_string_literal: true

class ViewPerspective < Perspective
  include ActionView::Helpers::TagHelper
  include Rails.application.routes.url_helpers

  attr_accessor :context
  delegate :output_buffer=, :output_buffer, to: :@context, allow_nil: true

  # @param [QuestionType, Symbol] type
  # @param [ActionView::Base] context
  #
  # @return [ViewPerspective]
  def self.get(type, context)
    super(type).tap do |perspective|
      perspective.context = context
    end
  end

  class Default < self
    def render(answers, alt: '-')
      if answers.present?
        answers.join(', ')
      else
        alt
      end
    end
  end
end
