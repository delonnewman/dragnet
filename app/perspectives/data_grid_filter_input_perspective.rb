# frozen_string_literal: true

class DataGridFilterInputPerspective < ViewPerspective
  default do
    def render(question, default_value)
      tag.input(
        class:        'form-control',
        type:         'search',
        name:         field_name(question),
        value:        default_value,
        autofocus:    !default_value.nil?,
        'hx-post':    survey_data_table_path(question.survey_id),
        'hx-trigger': 'keyup changed delay:500ms',
        'hx-target':  '#data-grid-table',
        'hx-vals':    { authenticity_token: context.session[:_csrf_token] }.to_json,
      )
    end
  end

  for_type :number do
    def render(question, default_value)
      tag.input(
        class:        'form-control',
        name:         field_name(question),
        type:         'number',
        value:        default_value,
        autofocus:    !default_value.nil?,
        'hx-post':    survey_data_table_path(question.survey_id),
        'hx-trigger': 'keyup changed delay:500ms,change',
        'hx-target':  '#data-grid-table',
        'hx-vals':    { authenticity_token: authenticity_token }.to_json,
      )
    end
  end

  for_type :time do
    # TODO: should support a date range
    def render(question, default_value)
      tag.input(
        class:        'form-control',
        name:         field_name(question),
        type:         'date',
        value:        default_value,
        autofocus:    !default_value.nil?,
        'hx-post':    survey_data_table_path(question.survey_id),
        'hx-trigger': 'change',
        'hx-target':  '#data-grid-table',
        'hx-vals':    { authenticity_token: authenticity_token }.to_json,
      )
    end
  end

  for_type :choice do
    # TODO: need a way to clear the value
    def render(question, default_value)
      htmx = {
        'hx-post':    survey_data_table_path(question.survey_id),
        'hx-trigger': 'change',
        'hx-target':  '#data-grid-table',
        'hx-vals':    { authenticity_token: authenticity_token }.to_json,
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

  for_type :boolean do
    def render(question, default_value)
      htmx = {
        'hx-post':    survey_data_table_path(question.survey_id),
        'hx-trigger': 'change',
        'hx-target':  '#data-grid-table',
        'hx-vals':    { authenticity_token: authenticity_token }.to_json,
      }
      tag.select(class: 'form-select', name: field_name(question), autofocus: !default_value.nil?, **htmx) do
        context.concat tag.option('Any')
        context.concat tag.option('-') unless question.required?
        context.concat tag.option(value: true) { 'Yes' }
        context.concat tag.option(value: false) { 'No' }
      end
    end
  end

  def authenticity_token
    context.session[:_csrf_token]
  end

  def field_name(question)
    "filter_by[#{question.id}]"
  end
end
