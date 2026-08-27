# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Map < TabbedView
    def tab_name
      'Map'
    end

    def tab_icon_class
      'fas fa-location-dot'
    end

    def types
      [Dragnet::Types::Address]
    end

    def initialize(survey:)
      @survey = survey
    end

    def view_template
      render Navbar.new(survey: @survey)
      render Tabs.new(selected: :map, survey: @survey)
    end
  end
end
