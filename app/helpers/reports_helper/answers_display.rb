# frozen_string_literal: true

module ReportsHelper
  class AnswersDisplay
    include Dragnet::Memoizable
    include ActionView::Helpers::TagHelper

    attr_reader :question_type

    delegate :output_buffer=, :output_buffer, to: :@context

    class << self
      def init(question_type, context)
        new(question_type, context)
      end
      alias [] init
    end
    memoize self: :init

    def initialize(question_type, context)
      @question_type = question_type
      @context = context
    end

    def to_html(reply, question, alt: '-')
      classes = %w[text-nowrap]
      classes << 'text-end' if question_type.is?(:number)

      tag.div(class: classes) do
        answers = reply.answers_to(question)
        if answers.present?
          answers.join(', ')
        else
          alt
        end
      end
    end
  end
end
