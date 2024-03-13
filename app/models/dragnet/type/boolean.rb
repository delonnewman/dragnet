# frozen_string_literal: true

module Dragnet
  class Type::Boolean < Type
    def data_grid_sort(_question, scope, direction, join_name)
      scope.order(Arel.sql("#{join_name}.boolean_value") => direction)
    end

    def data_grid_filter(_question, scope, table, value)
      scope.where(table => { boolean_value: value })
    end

    def assign_value!(answer, value)
      answer.boolean_value = value
    end

    def value(answer)
      answer.boolean_value
    end
  end
end
