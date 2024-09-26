# frozen_string_literal: true

class Ahoy::Event < Dragnet::ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = 'ahoy_events'

  belongs_to :visit
  belongs_to :user, class_name: 'Dragnet::User', optional: true

  has_one :reply, through: :visit
  has_one :survey, through: :reply
  has_one :survey_author, through: :survey, source: :author

  scope :with_survey_id, ->(survey_id) { joins(:survey).where(survey: { id: survey_id }) }
  scope :by_reply_event_tag, ->(tag) { where(name: Dragnet::ReplyTracker.event_name(tag)) }
end
