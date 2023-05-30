# frozen_string_literal: true

class DataGridFilterPerspective < ApplicationPerspective
  context :default do
    def render(question)
      tag.input(name: field_name(question), type: 'text')
    end
  end

  context :number do
    def render(question)
      tag.input(name: field_name(question), type: 'number')
    end
  end

  context :time do
    def render(question)
      tag.input(name: field_name(question), type: 'date')
    end
  end

  def field_name(question)
    "filter_by[#{question.id}]"
  end
end
