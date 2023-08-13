# frozen_string_literal: true

module Perspectives
  class AnswerStats < BasePerspective
    class Choice < self
      def collect(reportable, question)
        weight = question_options[:weight]

        data =
          reportable
            .answers
            .where(question: question)
            .joins(:question_option)
            .pick(min(weight), max(weight), sum(weight), avg(weight), stddev(weight))

        project_answer_stats(data)
      end
    end

    class Number < self
      def collect(reportable, question)
        name = question.settings.decimal? ? :float_value : :integer_value
        column = Answer.arel_table[name]

        data =
          reportable
            .answers
            .where(question: question)
            .pick(min(column), max(column), sum(column), avg(column), stddev(column))

        project_answer_stats(data)
      end
    end

    class Text < self
      def collect(reportable, question)
        column = Answer.arel_table[:float_value]

        data =
          reportable
            .answers
            .where(question: question)
            .pick(min(column), max(column), sum(column), avg(column), stddev(column))

        project_answer_stats(data)
      end
    end

    private

    def project_answer_stats(data)
      { 'Min'       => data[0].if_nil(0),
        'Max'       => data[1].if_nil(0),
        'Sum'       => data[2].if_nil(0),
        'Average'   => data[3].if_nil(0).round(1),
        'Std. Dev.' => data[4].if_nil(0).round(1) }
    end

    def question_options
      Arel::Table.new(:question_options)
    end

    def min(column)
      Arel::Nodes::NamedFunction.new('min', [column])
    end

    def max(column)
      Arel::Nodes::NamedFunction.new('max', [column])
    end

    def avg(column)
      Arel::Nodes::NamedFunction.new('avg', [column])
    end

    def sum(column)
      Arel::Nodes::NamedFunction.new('sum', [column])
    end

    def stddev(column)
      Arel::Nodes::NamedFunction.new('stddev', [column])
    end
  end
end
