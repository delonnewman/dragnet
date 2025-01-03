# frozen_string_literal: true

module Dragnet
  class FilterInputDisplay < Display
    attribute :question
    attribute :default_value

    def boolean
      htmx = {
        'hx-get':      survey_data_table_path(question.survey_id, passed_params),
        'hx-push-url': survey_data_path(question.survey_id, passed_params),
        'hx-trigger':  'change',
        'hx-target':   '#data-grid-table',
        'hx-swap':     'morph:innerHTML',
      }
      tag.select(class: 'form-select', name: field_name(question), autofocus: !default_value.nil?, **htmx) do
        context.concat tag.option('Any')
        context.concat tag.option(ALT_TEXT) unless question.required?
        context.concat tag.option(value: true) { 'Yes' }
        context.concat tag.option(value: false) { 'No' }
      end
    end

    def number
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

    def temporal
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

    def basic
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
