# frozen_string_literal: true

class DataGridDisplayPerspective < ApplicationPerspective
  context :default do
    def render(answers, alt: '-')
      classes = %w[text-nowrap]
      classes << 'text-end' if question_type.is?(:number)

      tag.div(class: classes) do
        if answers.present?
          answers.join(', ')
        else
          alt
        end
      end
    end
  end
end
