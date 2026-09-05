module Dragnet::Components
  class Icon < Base
    def self.[](style, name = nil, **attributes)
      klass = if name
                "#{style} fa-#{name}"
              else
                style
              end

      new(klass, **attributes)
    end

    def initialize(icon_class, **attributes)
      @icon_class = icon_class
      @attributes = attributes
    end

    def view_template
      i(**mix({ class: @icon_class }, @attributes))
    end
  end
end
