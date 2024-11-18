class Dragnet
  class Action::FilterDataGrid < Action
    private attr_reader :question, :scope, :table, :value

    def initialize(question:, scope:, table:, value:)
      @question = question
      @scope = scope
      @table = table
      @value = value
    end

    def boolean(type)
      scope.where(table => { boolean_value: value })
    end

    def number(type)
      if question.settings.decimal?
        scope.where(table => { float_value: value })
      else
        scope.where(table => { integer_value: value })
      end
    end

    def time(type)
      if question.settings.include_date?
        scope.where(table => { date_value: value })
      else
        scope.where(table => { time_value: value })
      end
    end

    def text(type)
      if question.settings.long_answer?
        scope.where.like(table => { long_text_value: "%#{value}%" })
      else
        scope.where.like(table => { short_text_value: "%#{value}%" })
      end
    end

    def choice(type)
      scope.where(table => { question_option_id: value })
    end
  end
end
