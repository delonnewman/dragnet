# frozen_string_literal: true

class Workspace
  extend Dragnet::Advising
  include Dragnet::Memoizable

  attr_reader :user

  delegate :surveys, :survey_ids, to: :user

  with RecentlyActiveSurveys, calling: :call
  with RepliesByDate, calling: :call
  with RepliesBySurveyAndDate, calling: :call

  def initialize(user)
    @user = user
  end

  def questions
    Question.where(survey_id: survey_ids)
  end
  memoize :questions

  def records
    Reply.where(survey_id: survey_ids, submitted: true)
  end
  memoize :records

  def events
    Ahoy::Event.with_survey_id(survey_ids)
  end
  memoize :events
end
