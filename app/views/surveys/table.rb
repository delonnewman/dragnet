# frozen_string_literal: true

module Dragnet::Views::Surveys
  class Table < TabbedView
    def self.tab_name =  'Records'
    def self.tab_icon_class = 'fas fa-table'
    def self.path(survey, context) = context.survey_data_path(survey)
  end
end
