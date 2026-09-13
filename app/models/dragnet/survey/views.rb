# frozen_string_literal: true

module Dragnet
  class Survey::Views
    def self.default
      @default ||= new.tap do |views|
        views[:summary] = Dragnet::Views::Surveys::Summary
        views[:table] = Dragnet::Views::Surveys::Table
        views[:map] = Dragnet::Views::Surveys::Map
        views.filter(
          :map,
          ->(survey, _) { survey.types.include?(Ext::Address) }
        )
      end
    end

    def initialize
      @views = {}
      @orderings = Hash.new(99)
      @filters = Hash.new(->(*) { true })
    end

    def []=(name, view)
      raise TypeError, 'Not a valid view' unless view <= Dragnet::Views::Base

      @views[name.to_sym] = view
    end

    def [](name)
      @views.fetch(name.to_sym) do
        raise "Unkown view #{name}"
      end
    end

    def order(name, value)
      @orderings[name] = value
    end

    def filter(name, filter)
      raise TypeError, 'Not a valid filter' unless filter.respond_to?(:call)

      @filters[name] = filter
    end

    def present(survey)
      @views.sort_by { |(name, _)| @orderings[name] }.tap do |views|
        views.select! { |(name, view)| @filters[name].call(survey, view) }
        views.map! { it[1] }
      end
    end
  end
end
