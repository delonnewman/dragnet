# frozen_string_literal: true

module Dragnet
  class Survey::Views
    def self.default
      @default = new.tap do |views|
        views[:summary] = Dragnet::Views::Summary.new
        views[:table] = Dragnet::Views::Table.new
        views[:map] = Dragnet::Views::Map.new
        views.filter(
          :map,
          ->(survey, view) { survey.types.include?(Ext::Address) }
        )
      end
    end

    def initialize
      @views = {}
      @orderings = Hash.new(99)
      @filters = Hash.new(->(*) { true })
    end

    def []=(name, view)
      raise TypeError, 'Not a valid view' unless view.is_a?(View)

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
      @views
        .sort_by { |(name, view)| @orderings[name] }
        .select { |(name, view)| @filters[name].call(survey, view) }
        .map! { it[1] }
    end
  end
end
