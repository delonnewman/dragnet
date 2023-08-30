# frozen_string_literal: true

module Dragnet
  module Perspectives
    class DataGridDisplay < ViewPerspective
      def render(answers, _question, alt: '-')
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

      class Time < self
        def render(answers, question, alt: '-')
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
      end

      class Boolean < self
        def render(answers, _question, alt: '-')
          return alt if answers.blank?

          answers.map do |answer|
            case answer.value
            when true
              'Yes'
            when false
              'No'
            else
              alt
            end
          end.join(', ')
        end
      end
    end
  end
end