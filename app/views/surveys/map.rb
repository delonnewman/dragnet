# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Map < TabbedView
    def tab_name
      'Map'
    end

    def tab_icon_class
      'fas fa-location-dot'
    end
  end
end
