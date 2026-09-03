module Dragnet::Views::Surveys
  class Tabs < Dragnet::Views::Base
    def initialize(survey:, selected: nil)
      @survey   = survey
      @selected = selected
    end

    def view_template
      ul(class: 'nav nav-tabs', hx: { boost: true }) do
        render NavItem.new(href: root_path, hx: { boost: false }) do
          render Icon['fas', 'arrow-left']
          plain ' Back to Workspace'
        end
        render NavItem.new(href: survey_path(@survey), active: @selected == :summary) do
          if @selected == :summary
            render Icon['fas', 'gauge']
            plain ' '
          end
          plain 'Summary'
        end
        render NavItem.new(href: survey_data_path(@survey), active: @selected == :data) do
          if @selected == :data
            render Icon['fas', 'table']
            plain ' '
          end
          plain 'Records'
        end
        render NavItem.new(href: survey_map_path(@survey), active: @selected == :map) do
          if @selected == :map
            render Icon['fas', 'location-dot']
            plain ' '
          end
          plain 'Map'
        end
      end
    end # template
  end
end
