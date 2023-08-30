# frozen_string_literal: true

module Perspectives
  class DataGridFilterInput < ViewPerspective
    def render(question, default_value)
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

    class Number < self
      def render(question, default_value)
        tag.input(
          class:         'form-control',
          name:          field_name(question),
          type:          'number',
          inputmode:     'numeric',
          value:         default_value,
          'hx-get':      survey_data_table_path(question.survey_id, passed_params),
          'hx-push-url': survey_data_path(question.survey_id, passed_params),
          'hx-trigger':  'keyup changed delay:500ms,change',
          'hx-target':   '#data-grid-table',
          'hx-swap':     'morph:innerHTML',
        )
      end
    end

    class Time < self
      # TODO: should support a date range
      def render(question, default_value)
        tag.input(
          class:         'form-control',
          name:          field_name(question),
          type:          'date',
          value:         default_value,
          'hx-get':      survey_data_table_path(question.survey_id, passed_params),
          'hx-push-url': survey_data_path(question.survey_id, passed_params),
          'hx-trigger':  'change',
          'hx-target':   '#data-grid-table',
          'hx-swap':     'morph:innerHTML',
        )
      end
    end

    class Choice < self
      # TODO: need a way to clear the value
      def render(question, default_value)
        htmx = {
          'hx-get':      survey_data_table_path(question.survey_id, passed_params),
          'hx-push-url': survey_data_path(question.survey_id, passed_params),
          'hx-trigger':  'change',
          'hx-target':   '#data-grid-table',
          'hx-swap':     'morph:innerHTML',
        }
        tag.select(class: 'form-select', name: field_name(question), autofocus: !default_value.nil?, **htmx) do
          context.concat tag.option('Any')
          context.concat tag.option('-') unless question.required?
          question.question_options.each do |option|
            context.concat tag.option(value: option.id, selected: (option.weight.present? && option.weight == default_value) || option.text == default_value) { option.text }
          end
        end
      end
    end

    class Boolean < self
      def render(question, default_value)
        htmx = {
          'hx-get':      survey_data_table_path(question.survey_id, passed_params),
          'hx-push-url': survey_data_path(question.survey_id, passed_params),
          'hx-trigger':  'change',
          'hx-target':   '#data-grid-table',
          'hx-swap':     'morph:innerHTML',
        }
        tag.select(class: 'form-select', name: field_name(question), autofocus: !default_value.nil?, **htmx) do
          context.concat tag.option('Any')
          context.concat tag.option('-') unless question.required?
          context.concat tag.option(value: true) { 'Yes' }
          context.concat tag.option(value: false) { 'No' }
        end
      end
    end

    def field_name(question)
      "filter_by[#{question.id}]"
    end

    def passed_params
      context.data_grid_params
    end
  end
end
