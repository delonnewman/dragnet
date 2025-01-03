# frozen_string_literal: true

module Dragnet
  # Modify the data grid relation to filter records
  class DataGrid::Filter < TypeMethod
    attribute :relation
    attribute :table
    attribute :value

    def boolean
      relation.where(table => { boolean_value: value })
    end

    def decimal
      relation.where(table => { float_value: value })
    end

    def integer
      relation.where(table => { integer_value: value })
    end

    def time
      relation.where(table => { time_value: value })
    end

    def date
      relation.where(table => { date_value: value })
    end
    alias date_and_time date

    def text
      relation.where.like(table => { short_text_value: "%#{value}%" })
    end

    def long_text
      relation.where.like(table => { long_text_value: "%#{value}%" })
    end

    def choice
      relation.where(table => { question_option_id: value })
    end
  end
end
