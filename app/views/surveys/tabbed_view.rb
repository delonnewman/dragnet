module Dragnet::Views
  class TabbedView < Base
    def tab_name
      raise NoMethodError
    end

    def tab_icon_class
      raise NoMethodError
    end
  end
end
