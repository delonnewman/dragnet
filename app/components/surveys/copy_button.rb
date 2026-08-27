module Dragnet::Components
  class Surveys::CopyButton < Base
    def initialize(survey:, include_label: false)
      @survey = survey
      @include_label = include_label
    end

    def view_template
      render IconButton.new(
        label: @include_label ? 'Duplicate' : nil,
        path: copy_survey_path(@survey),
        icon: 'clone',
        title: 'Duplicate this survey',
        data: { bs_toggle: 'tooltip' },
        class: 'btn btn-sm btn-outline-secondary me-1'
      )
    end
  end
end
