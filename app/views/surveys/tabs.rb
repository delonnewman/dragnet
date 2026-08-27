module Dragnet::Views::Surveys
  class Tabs < Dragnet::Views::Base
    def initialize(survey:, selected: nil)
      @survey   = survey
      @selected = selected
    end

    def view_template
      ul(class: 'nav nav-tabs mb-3', hx: { boost: true }) do
        li(class: 'nav-item') do
          a(href: root_path, hx: { boost: false }, class: 'nav-link') do
            render Icon['fas', 'arrow-left']
            plain ' Back to Workspace'
          end
        end
        li(class: 'nav-item') do
          a(href: survey_path(@survey), class: ['nav-link', ('active' if @selected == :summary)]) do
            if @selected == :summary
              render Icon['fas', 'gauge']
              plain ' '
            end
            plain 'Summary'
          end
        end
        li(class: 'nav-item') do
          a(href: survey_data_path(@survey), class: ['nav-link', ('active' if @selected == :data)]) do
            if @selected == :data
              render Icon['fas', 'table']
              plain ' '
            end
            plain 'Records'
          end
        end
        li(class: 'nav-item') do
          a(href: survey_map_path(@survey), class: ['nav-link', ('active' if @selected == :map)]) do
            if @selected == :map
              render Icon['fas', 'location-pin-alt']
              plain ' '
            end
            plain 'Map'
          end
        end
      end
    end # template
  end
end
