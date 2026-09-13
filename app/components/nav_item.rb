module Dragnet
  module Components
    class NavItem < Base
      def initialize(active: false, **attributes)
        @attributes = attributes
        return unless active

        @attributes[:class] ||= []
        @attributes[:class] << 'active'
      end

      def view_template
        li(class: 'nav-item') do
          a(**mix({ class: 'nav-link' }, @attributes)) do
            yield
          end
        end
      end
    end
  end
end
