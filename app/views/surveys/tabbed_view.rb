# frozen_string_literal: true

module Dragnet::Views::Surveys
  class TabbedView < Dragnet::Views::Base
    def self.tab_name
      raise NoMethodError
    end

    def self.tab_icon_class
      raise NoMethodError
    end

    def self.types = nil

    def initialize(survey:)
      @survey = survey
    end

    def around_template
      render Navbar.new(survey: @survey)
      render Tabs.new(selected: :map, survey: @survey)
      super
    end
  end
end
