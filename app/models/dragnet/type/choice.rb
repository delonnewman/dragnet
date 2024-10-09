# frozen_string_literal: true

module Dragnet
  class Type::Choice < Type
    def data_grid_sort(_question, scope, direction, join_name)
      scope.order(sanitize_sql_for_order("#{join_name}.question_option_id") => direction)
    end

    def data_grid_filter(_question, scope, table, value)
      scope.where(table => { question_option_id: value })
    end

    def stats_table(reportable, question)
      weight = question_options[:weight]

      data =
        reportable
          .answers
          .where(question: question)
          .joins(:question_option)
          .pick(min(weight), max(weight), sum(weight), avg(weight), stddev(weight))

      project_stats_table(data)
    end

    def occurrence_table(reportable, question)
      opts = question.question_options.reduce({}) { |table, opt| table.merge!(opt.id => opt.text) }
      data = reportable.answers.where(question:).group(:question_option_id).count

      data.transform_keys(&opts)
    end

    def assign_value!(answer, value)
      answer.question_option_id = value
    end

    def value(answer)
      answer.question_option&.text
    end

    def number_value(answer)
      answer.question_option&.weight
    end
  end
end
