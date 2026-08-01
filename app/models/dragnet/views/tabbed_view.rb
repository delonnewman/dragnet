module Dragnet
  class Views::TabbedView < View
    def tab_name
      raise NoMethodError
    end

    def tab_icon_class
      raise NoMethodError
    end
  end
end
