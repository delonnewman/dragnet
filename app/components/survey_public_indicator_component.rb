# frozen_string_literal: true

class SurveyPublicIndicatorComponent < Dragnet::Component
  attribute :survey, required: true

  template do
    span do
      list << icon(type: 'fas', name: icon_name)
      list << space(non_breaking: true)
      list << indicator_text
    end
  end

  def indicator_text
    survey.public? ? 'Public' : 'Private'
  end

  EARTH_REGIONS = %w[americas europe asia oceania africa].freeze

  def icon_name
    survey.public? ? "earth-#{EARTH_REGIONS.sample}" : 'key'
  end
end
