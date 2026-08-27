module Dragnet::Components
  class Icon < Base
    def self.[](style, name, **attributes)
      new(style:, name:, **attributes)
    end

    def initialize(style:, name:, **attributes)
      @style      = style
      @name       = name
      @attributes = attributes
    end

    def view_template
      i(**mix({ class: "#@style fa-#@name" }, @attributes))
    end
  end
end
