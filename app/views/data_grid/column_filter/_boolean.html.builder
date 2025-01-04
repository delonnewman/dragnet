# locals: (question:, data_grid_params:, default_value:)

htmx = {
  'hx-get':      survey_data_table_path(question.survey_id, data_grid_params),
  'hx-push-url': survey_data_path(question.survey_id, data_grid_params),
  'hx-trigger':  'change',
  'hx-target':   '#data-grid-table',
  'hx-swap':     'morph:innerHTML',
}

xml.select(class: 'form-select', name: question.field_name, autofocus: default_value.present?, **htmx) do
  xml.option('Any')
  xml.option('-') unless question.required?
  xml.option('Yes', value: true)
  xml.option('No', value: false)
end
