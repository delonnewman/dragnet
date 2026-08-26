# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Table < TabbedView
    def tab_name
      'Records'
    end

    def tab_icon_class
      'fas fa-table'
    end
  end
end
