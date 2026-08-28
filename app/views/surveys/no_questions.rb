module Dragnet::Views::Surveys
  class NoQuestions < Dragnet::Views::Base
    def initialize(survey:)
      @survey = survey
    end

    def view_template
      p(class: 'text-center mt-5 mx-auto', style: 'max-width:500px') do
        render Icon['fas', 'helmet-safety', class: 'h1 text-muted']
      end
      p(class: 'mx-auto text-center lead mb-0', style: 'max-width:500px') do
        'The smell of potential is in the air!'
      end
      p(class: 'mx-auto text-center', style: 'max-width:500px') do
        plain "If you're ready to get started "
        a(href: edit_survey_path(@survey)) { 'click here' }
        plain '.'
      end
    end
  end
end
