# frozen_string_literal: true

class DataGridSortQueryPerspective < Perspective
  for_type :default do
    def sort(_question, _scope, _direction)
      raise "can't sort questions of type: #{question_type}"
    end
  end

  for_type :text do
    def sort(_question, scope, direction)
      # TODO: should test for short or long text
      scope.order(short_text_value: direction)
    end
  end

  for_type :time do
    def sort(_question, scope, direction)
      # TODO: should test for time only and use the time_value field
      scope.order(date_value: direction, time_value: direction)
    end
  end

  for_type :number do
    def sort(_question, scope, direction)
      # TODO: should test for whether it's a decimal or float and use the appropriate attribute
      scope.order(integer_value: direction)
    end
  end

  for_type :choice do
    def sort(_question, scope, direction)
      scope.order(question_option_id: direction)
    end
  end

  for_type :boolean do
    def sort(_question, scope, direction)
      scope.order(boolean_value: direction)
    end
  end
end
