# frozen_string_literal: true

module Dragnet
  # @abstract
  # An abstract class for type view objects.
  class Type::View
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers

    attr_reader :type, :context

    delegate :question_type, to: :@type
    delegate :output_buffer=, :output_buffer, :params, to: :@context, allow_nil: true

    def self.for(type, ...)
      klass = "#{type.class}View".safe_constantize
      return new(type, ...) unless klass && klass < self

      klass.new(type, ...)
    end

    def initialize(type, context:)
      @type = type
      @context = context
    end

    def data_grid_edit_input(_answers)
    end

    def data_grid_display(answers, _question, alt: '-')
      classes = %w[text-nowrap]
      classes << 'text-end' if question_type.is?(:number)

      tag.div(class: classes) do
        if answers.present?
          answers.join(', ')
        else
          alt
        end
      end
    end

    def data_grid_filter_input(question, default_value)
      tag.input(
        class:         'form-control',
        type:          'search',
        inputmode:     'search',
        name:          field_name(question),
        value:         default_value,
        'hx-get':      survey_data_table_path(question.survey_id, passed_params),
        'hx-push-url': survey_data_path(question.survey_id, passed_params),
        'hx-trigger':  'keyup changed delay:500ms,change',
        'hx-target':   '#data-grid-table',
        'hx-swap':     'morph:innerHTML',
        )
    end

    private

    def field_name(question)
      "filter_by[#{question.id}]"
    end

    def passed_params
      context.data_grid_params
    end
  end
end
