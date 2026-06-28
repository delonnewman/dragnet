# frozen_string_literal: true

module Dragnet
  class DataGrid::RenderAnswersText < TypeHelperMethod
    attribute :answers
    attribute :question
    attribute :alt_text

    def boolean
      return alt_text if answers.blank?

      answers.map do |answer|
        case answer.value
        when true
          'Yes'
        when false
          'No'
        else
          alt_text
        end
      end.join(', ')
    end

    def temporal
      return alt_text if answers.blank?

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

    def basic
      classes = %w[text-nowrap]
      classes << 'text-end' if type.is_a?(Types::Number)

      tag.div(class: classes) do
        if answers.present?
          answers.join(', ')
        else
          alt_text
        end
      end
    end
  end
end
