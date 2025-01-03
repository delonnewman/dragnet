# locals: (question:, data_grid_params:, default_value:)

xml.input(
  class:         'form-control',
  type:          'search',
  inputmode:     'search',
  name:          question.field_name,
  value:         default_value,
  'hx-get':      survey_data_table_path(question.survey_id, data_grid_params),
  'hx-push-url': survey_data_path(question.survey_id, data_grid_params),
  'hx-trigger':  'keyup changed delay:500ms,change',
  'hx-target':   '#data-grid-table',
  'hx-swap':     'morph:innerHTML',
)
