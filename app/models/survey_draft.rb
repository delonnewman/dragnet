class SurveyDraft < ApplicationRecord
  belongs_to :survey

  serialize :survey_data

  def_delegators :draft, :valid?, :validate!, :errors

  def draft
    @draft ||= Survey.new(survey_data)
  end

  def published!(published_at = Time.now)
    self.published = true
    self.published_at = published_at
    self
  end
end
