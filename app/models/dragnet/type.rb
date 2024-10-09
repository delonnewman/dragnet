module Dragnet
  class Type
    # include sql sanitation methods from ActiveRecord
    include ActiveRecord::Sanitization::ClassMethods

    attr_reader :question_type

    def initialize(question_type)
      @question_type = question_type
    end

    def data_grid_sort(_question, _scope, _direction, _join_name)
      raise "can't sort questions of type: #{question_type}"
    end

    def data_grid_filter(_question, _scope, _table, _value)
      raise "can't filter questions of type: #{question_type}"
    end

    def before_saving_answer(_answer, _question)
      # do nothing
    end

    def stats_table(_reportable, _question)
      raise "can't collect stats for type: #{question_type}"
    end

    def occurrence_table(_reportable, _question)
      raise "can't collect occurrence stats for type: #{question_type}"
    end

    # Assign the given value to the appropriate attribute
    # @param [Answer] answer
    # @param [Object, nil] value
    def assign_value!(answer, value)
      raise Answer::EvaluationError, "can't evaluate #{value.inspect}:#{value.class} for #{answer.question_type}"
    end

    # @param [Answer] answer
    # @return [Object, nil] the evaluated answer
    def value(answer)
      raise Answer::EvaluationError, "can't get value from question type: #{answer.question_type}"
    end

    # Return a numeric value that is appropriate for the type. Will be used in calculations and dashboards
    # @param [Answer] answer
    # @return [Numeric, nil]
    def number_value(answer)
      raise Answer::EvaluationError, "can't convert #{answer.question_type} to number"
    end

    private

    def project_stats_table(data)
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
