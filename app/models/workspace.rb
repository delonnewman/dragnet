# frozen_string_literal: true

class Workspace
  extend Dragnet::Advising

  attr_reader :user

  with RecentlyActiveSurveys, calling: :call
  with RepliesByDate, calling: :call
  with RepliesBySurveyAndDate, calling: :call

  def initialize(user)
    @user = user
  end
end
