# frozen_string_literal: true

module Dragnet
  class Type::BooleanView < Type::View
    def data_grid_display(answers, _question, alt: '-')
      return alt if answers.blank?

      answers.map do |answer|
        case answer.value
        when true
          'Yes'
        when false
          'No'
        else
          alt
        end
      end.join(', ')
    end

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
        context.concat tag.option(value: true) { 'Yes' }
        context.concat tag.option(value: false) { 'No' }
      end
    end
  end
end
