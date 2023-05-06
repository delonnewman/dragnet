# frozen_string_literal: true

class PublicIndicatorComponent < ApplicationComponent
  EARTH_REGIONS = %w[americas europe asia oceania africa].freeze

  attribute :survey, required: true

  let(:indicator_text) { survey.public? ? 'Public' : 'Private' }
  let(:icon_name) { survey.public? ? "earth-#{EARTH_REGIONS.sample}" : 'key' }

  template do
    tag.span do
      tag.icon(type: 'fas', name: icon_name) + tag.nbsp + indicator_text
    end
  end
end
