# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Summary < TabbedView
    def self.tab_name = 'Summary'
    def self.tab_icon_class = 'fas ga-guage'

    def view_template
      if @survey.not_ready_for_replies?
        render NoQuestions.new(survey: @survey)
      elsif @survey.no_data?
        render NoReplies.new(survey: @survey)
      else
        render Dragnet::Views::Stats::Summary.new(report: @survey.stats_report)
      end
    end
  end
end
