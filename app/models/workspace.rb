# frozen_string_literal: true

class Workspace
  attr_reader :user

  with RecentlyActiveSurveys
  with RepliesByDate
  with RepliesBySurveyAndDate

  def initialize(user)
    @user = user
  end
end
