# frozen_string_literal: true

module Dragnet
  class DataGrid::RenderAnswersText < TypeHelperMethod
    attribute :answers
    attribute :question
    attribute :alt_text

    def boolean
      return alt_text if answers.blank?

      value = answers.first.value
      case value
      when true
        'Yes'
      when false
        'No'
      else
        alt_text
      end
    end

    def temporal
      return alt_text if answers.blank?

      value = answers.first.value
      tag.div(class: 'text-nowrap text-end') do
        if question.settings.include_date_and_time?
          context.format_datetime(value)
        elsif question.settings.include_time?
          context.format_time(value)
        else
          context.format_date(value)
        end
      end
    end

    def basic
      classes = %w[text-nowrap]
      classes << 'text-end' if type.is_a?(Types::Number)

      tag.div(class: classes) do
        if answers.present?
          answers.first.text_value
        else
          alt_text
        end
      end
    end
  end
end
