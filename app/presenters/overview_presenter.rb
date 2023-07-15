# frozen_string_literal: true

class OverviewPresenter < Dragnet::View::Presenter
  presents Workspace, as: :space

  delegate :replies_by_date, to: :space

  def surveys = space.recently_active_surveys(last_created: Time.zone.now.end_of_day, limit: 8)

  def user_stats = StatsReport.new(user)
  memoize :user_stats

  def query_desc = Workspace::RecentlyActiveSurveys.query_doc

  def survey_count = user.surveys.count
  memoize :survey_count
end
