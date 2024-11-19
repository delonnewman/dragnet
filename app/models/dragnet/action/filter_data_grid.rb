module Dragnet
  class Action::FilterDataGrid < Action
    attribute :question
    attribute :scope
    attribute :table
    attribute :value

    def boolean
      scope.where(table => { boolean_value: value })
    end

    def number
      if question.settings.decimal?
        scope.where(table => { float_value: value })
      else
        scope.where(table => { integer_value: value })
      end
    end

    def time
      scope.where(table => { time_value: value })
    end

    def date
      scope.where(table => { date_value: value })
    end
    alias date_and_time date

    def text
      if question.settings.long_answer?
        scope.where.like(table => { long_text_value: "%#{value}%" })
      else
        scope.where.like(table => { short_text_value: "%#{value}%" })
      end
    end

    def choice
      scope.where(table => { question_option_id: value })
    end
  end
end
