module Dragnet::Views::Surveys
  class NoReplies < Dragnet::Views::Base
    def initialize(survey:)
      @survey = survey
    end

    def view_template
      p(class: 'text-center mt-5 mx-auto', style: 'max-width:500px') do
        Icon['far', 'paper-plane', class: 'h1 text-muted']
      end
      p(class: 'mx-auto text-center lead mb-0', style: 'max-width:500px') do
        plain "Awesome! You've created a new #{@survey.kind_name}."
      end
      p(class: 'mx-auto', style: 'max-width:500px') do
        plain 'Now you can send out a link to your users.'
        a(href: share_survey_path(@survey)) { plain 'Click here' }
        whitespace
        plain 'to do so, and combacke here to see your data.'
      end
    end
  end
end
