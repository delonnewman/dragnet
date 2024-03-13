# frozen_string_literal: true

module Dragnet
  class Type::NumberView < Type::View
    def data_grid_filter_input(question, default_value)
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
end