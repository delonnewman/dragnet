module Dragnet::Components
  class Surveys::OpenIndicator < Base
    include Phlex::Rails::Helpers::Request

    attr_reader :id, :target

    delegate :open?, to: :@survey

    def initialize(survey:)
      @survey = survey
      @id     = "survey-#{@survey.id}-open"
      @target = "#survey-card-#{@survey.id}"
    end

    def view_template
      div(class: 'd-flex align-items-center ms-2 me-2') do
        render FormSwitch.new(id:, input_attributes:, label_attributes:) do
          render Icon['fas', open? ? 'lock-open' : 'lock', class: 'text-muted']
        end
      end
    end

    def label_attributes
      { style: 'width:18px;' }
    end

    def input_attributes
      {
        checked: open?,
        hx: htmx_attributes,
      }
    end

    def htmx_attributes
      {
        'post'    => path,
        'vals'    => post_params.to_json,
        'target'  => target,
        'swap'    => 'outerHTML',
        'trigger' => 'change',
      }
    end

    def path
      @survey.open? ? close_survey_path(@survey) : open_survey_path(@survey)
    end

    def post_params
      { authenticity_token: }
    end

    def authenticity_token
      request.commit_csrf_token
    end
  end
end
