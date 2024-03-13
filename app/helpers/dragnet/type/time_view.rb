# frozen_string_literal: true

module Dragnet
  class Type::TimeView < Type::View
    def data_grid_display(answers, question, alt: '-')
      return alt if answers.blank?

      tag.div(class: 'text-nowrap text-end') do
        answers.map do |answer|
          if question.settings.include_date_and_time?
            context.format_datetime(answer.value)
          elsif question.settings.include_time?
            context.format_time(answer.value)
          else
            context.format_date(answer.value)
          end
        end.join(', ')
      end
    end

    # TODO: should support a date range
    def data_grid_filter_input(question, default_value)
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
end
