# frozen_string_literal: true

module Dragnet
  class DataGrid::GetTextAlignment < TypeHelperMethod
    def basic
      'start'
    end

    def number
      'end'
    end

    def temporal
      'end'
    end
  end
end
