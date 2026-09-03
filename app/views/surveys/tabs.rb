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
        @survey.views.each do |view| 
          render NavItem.new(href: view.path(@survey, view_context), active: view.selected?(@selected)) do
            if view.selected?(@selected)
              render Icon[view.tab_icon_class]
              plain ' '
            end
            plain view.tab_name
          end
        end
      end
    end # template
  end
end
