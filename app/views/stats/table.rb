module Dragnet::Views::Stats
  class Table < Dragnet::Views::Base
    include StatsHelper
    include Phlex::Rails::Helpers::NumberWithDelimiter
    include Phlex::Rails::Helpers::NumberToPercentage
    
    def initialize(report:)
      @report = report
    end

    def view_template
      table(class: 'stats-table') do
        thead do
          th { 'View' }
          th { 'Replies' }
          th { 'Completion Rate' }
        end
        tbody do
          tr do
            td { stats_value @report.view_count }
            td { stats_value @report.reply_count }
            td { stats_percentage @report.completion_rate, precision: 0 }
          end
        end
      end
    end
  end
end
