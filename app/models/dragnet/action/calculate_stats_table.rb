# frozen_string_literal: true

module Dragnet
  class Action::CalculateStatsTable < GenericFunction
    attribute :reportable
    attribute :question

    def number
      name = question.settings.decimal? ? :float_value : :integer_value

      collect_stats(question, column: Answer.arel_table[name])
    end

    def text
      raise "can't collect stats for text unless the setting is turned on" unless type.calculate_sentiment?(question)

      collect_stats(question, column: Answer.arel_table[:float_value])
    end

    def choice
      collect_stats(question, column: QuestionOption.arel_table[:weight])
    end

    private

    attr_reader :reportable, :question

    def collect_stats(question, column:)
      data =
        reportable
          .answers
          .where(question:)
          .pick(min(column), max(column), sum(column), avg(column), stddev(column))

      project_stats_table(data)
    end

    def project_stats_table(data)
      { 'Min'       => data[0].if_nil(0),
        'Max'       => data[1].if_nil(0),
        'Sum'       => data[2].if_nil(0),
        'Average'   => data[3].if_nil(0).round(1),
        'Std. Dev.' => data[4].if_nil(0).round(1) }
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
