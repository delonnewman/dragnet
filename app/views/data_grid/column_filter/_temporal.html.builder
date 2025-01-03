# locals: (question:, data_grid_params:, default_value:)

xml.input(
  class:         'form-control',
  name:          question.field_name,
  type:          'date',
  value:         default_value,
  'hx-get':      survey_data_table_path(question.survey_id, data_grid_params),
  'hx-push-url': survey_data_path(question.survey_id, data_grid_params),
  'hx-trigger':  'change',
  'hx-target':   '#data-grid-table',
  'hx-swap':     'morph:innerHTML',
)
