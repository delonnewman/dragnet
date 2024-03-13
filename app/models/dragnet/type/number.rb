# frozen_string_literal: true

module Dragnet
  class Type::Number < Type
    def data_grid_sort(question, scope, direction, join_name)
      if question.settings.decimal?
        scope.order(Arel.sql("#{join_name}.float_value") => direction)
      else
        scope.order(Arel.sql("#{join_name}.integer_value") => direction)
      end
    end

    def data_grid_filter(question, scope, table, value)
      if question.settings.decimal?
        scope.where(table => { float_value: value })
      else
        scope.where(table => { integer_value: value })
      end
    end

    def stats_table(reportable, question)
      name = question.settings.decimal? ? :float_value : :integer_value
      column = Answer.arel_table[name]

      data =
        reportable
          .answers
          .where(question: question)
          .pick(min(column), max(column), sum(column), avg(column), stddev(column))

      project_stats_table(data)
    end

    def occurrence_table(reportable, question)
      if question.settings.decimal?
        reportable.answers.where(question:).group(:float_value).count
      else
        reportable.answers.where(question:).group(:integer_value).count
      end
    end

    def assign_value!(answer, value)
      return answer.float_value if answer.question.settings.decimal?

      answer.integer_value = value
    end

    def value(answer)
      if answer.question.settings.decimal?
        answer.float_value
      else
        answer.integer_value
      end
    end

    alias number_value value
  end
end
