# frozen_string_literal: true

class DataGridFilterInputPerspective < ApplicationPerspective
  context :default do
    def render(question, default_value)
      htmx = {
        'hx-post' => context.survey_data_table_path(question.survey_id),
        'hx-trigger' => 'keyup changed delay:500ms',
        'hx-target' => '#data-grid-table',
        'hx-vals' => { authenticity_token: context.session[:_csrf_token] }.to_json,
      }
      tag.input(class: 'form-control', type: 'search', name: field_name(question), value: default_value, **htmx)
    end
  end

  context :number do
    def render(question, default_value)
      tag.input(class: 'form-control', name: field_name(question), type: 'number', value: default_value)
    end
  end

  context :time do
    def render(question, default_value)
      tag.input(class: 'form-control', name: field_name(question), type: 'date', value: default_value)
    end
  end

  def field_name(question)
    "filter_by[#{question.id}]"
  end
end
