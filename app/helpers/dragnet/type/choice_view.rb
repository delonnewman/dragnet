# frozen_string_literal: true

module Dragnet
  class Type::ChoiceView < Type::View
    def data_grid_filter_input(question, default_value)
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
end
