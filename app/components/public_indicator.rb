module Dragnet::Components
  class PublicIndicator < Base
    EARTH_REGIONS = %w[americas europe asia oceania africa].freeze

    def initialize(survey:)
      @survey = survey
    end

    def view_template
      label = @survey.public? ? 'Public' : 'Private'

      render Icon['fas', @survey.public? ? "earth-#{EARTH_REGIONS.sample}" : 'key']
      whitespace
      plain label
    end
  end
end

