module Dragnet::Views::Stats
  class DataTable < Dragnet::Views::Base
    include Phlex::Rails::Helpers::NumberWithDelimiter

    # @param data [Hash{Symbol | String, Numeric}]
    # @param options [Hash{Symbol, Object}]
    def initialize(data:, **options)
      @data = data
      @options = options
    end

    def view_template
      table(class: 'table') do
        tbody do
          @data.map do |key, value|
            th { key }
            td { number_with_delimiter(value, **@options) }
          end
        end
      end
    end
  end
end
