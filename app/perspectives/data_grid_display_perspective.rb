# frozen_string_literal: true

class DataGridDisplayPerspective < ViewPerspective
  default do
    def render(answers, question, alt: '-')
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

  for_type :time do
    def render(answers, question, alt: '-')
      return alt unless answers.present?

      tag.div(class: 'text-nowrap text-end') do
        answers.filter_map do |answer|
          if question.include_date? && question.include_time?
            context.format_datetime(answer.value)
          elsif question.include_time?
            context.format_time(answer.value)
          else
            context.format_date(answer.value)
          end
        end.join(', ')
      end
    end
  end
end
