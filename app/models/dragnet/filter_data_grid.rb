# frozen_string_literal: true

module Dragnet
  # Modify the data grid relation to filter records
  class FilterDataGrid < GenericFunction
    attribute :question
    attribute :relation
    attribute :table
    attribute :value

    def boolean
      relation.where(table => { boolean_value: value })
    end

    def number
      if question.settings.decimal?
        relation.where(table => { float_value: value })
      else
        relation.where(table => { integer_value: value })
      end
    end

    def time
      relation.where(table => { time_value: value })
    end

    def date
      relation.where(table => { date_value: value })
    end
    alias date_and_time date

    def text
      if question.settings.long_answer?
        relation.where.like(table => { long_text_value: "%#{value}%" })
      else
        relation.where.like(table => { short_text_value: "%#{value}%" })
      end
    end

    def choice
      relation.where(table => { question_option_id: value })
    end
  end
end
