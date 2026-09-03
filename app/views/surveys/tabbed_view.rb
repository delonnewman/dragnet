# frozen_string_literal: true

module Dragnet::Views::Surveys
  class TabbedView < Dragnet::Views::Base
    extend Phlex::Rails::Helpers::Routes

    def self.tab_name
      raise NoMethodError
    end

    def self.tab_icon_class
      raise NoMethodError
    end

    def self.path(_survey, _context)
      raise NoMethodError
    end

    def self.symbol
      name.split('::').last.downcase.to_sym
    end

    def self.selected?(value)
      symbol == value
    end

    def self.types = nil

    delegate :symbol, to: 'self.class'

    def initialize(survey:, selected: symbol)
      @survey = survey
      @selected = selected
    end

    def around_template
      render Navbar.new(survey: @survey)
      render Tabs.new(selected: @selected, survey: @survey)
      div(class: 'container-fluid mt-3 mb-4') do
        super
      end
    end
  end
end
