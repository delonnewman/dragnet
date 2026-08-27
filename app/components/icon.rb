module Dragnet::Components
  class Icon < Base
    def self.[](style, name)
      new(style:, name:)
    end

    def initialize(style:, name:)
      @style = style
      @name  = name
    end

    def view_template
      i(class: "#@style fa-#@name")
    end
  end
end
