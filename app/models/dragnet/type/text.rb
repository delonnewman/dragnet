# frozen_string_literal: true

module Dragnet
  class Type::Text < Type
    def data_grid_sort(question, scope, direction, join_name)
      if question.settings.long_answer?
        scope.order(Arel.sql("#{join_name}.long_text_value") => direction)
      else
        scope.order(Arel.sql("#{join_name}.short_text_value") => direction)
      end
    end

    def data_grid_filter(question, scope, table, value)
      if question.settings.long_answer?
        scope.where.like(table => { long_text_value: "%#{value}%" })
      else
        scope.where.like(table => { short_text_value: "%#{value}%" })
      end
    end

    def before_saving_answer(answer, question)
      return unless question.settings.long_answer? && question.settings.countable?

      answer.float_value = Dragnet::TextSentiment.new(answer.long_text_value).score
    end

    def stats_table(reportable, question)
      column = Answer.arel_table[:float_value]

      data =
        reportable
          .answers
          .where(question: question)
          .pick(min(column), max(column), sum(column), avg(column), stddev(column))

      project_stats_table(data)
    end

    def occurrence_table(reportable, question)
      reportable.answers.where(question:).group(:float_value).count
    end

    def assign_value!(answer, value)
      if answer.question.settings.long_answer?
        answer.long_text_value = value
      else
        answer.short_text_value = value
      end
    end

    def value(answer)
      return answer.long_text_value if answer.question.settings.long_answer?

      answer.short_text_value
    end

    alias sort_value value
  end
end
