module Dragnet::Views::Surveys
  class Navbar < Dragnet::Views::Base
    include Dragnet::Components::Surveys

    def initialize(survey:)
      @survey = survey
    end

    def view_template
      div(class: 'navbar navbar-expland-lg p-1 bg-light mb-2') do
        div(class: 'container-fluid') do
          span(class: 'navbar-text text-dark') do
            plain @survey.name
            whitespace
            span(class: 'badge bg-secondary') do
              render PublicIndicator.new(survey: @survey)
            end
          end
          div(class: 'd-flex justify-content-end align-items-center') do
            render OpenIndicator.new(survey: @survey) unless @survey.public?
            render CopyButton.new(survey: @survey, include_label: true)
          end
        end
      end
    end
  end
end
