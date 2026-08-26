# frozen_string_literal: true

module Dragnet::Views::Surveys
  class TabbedView < Dragnet::Views::Base
    def tab_name
      raise NoMethodError
    end

    def tab_icon_class
      raise NoMethodError
    end
  end
end
