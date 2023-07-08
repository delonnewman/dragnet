# frozen_string_literal: true

class OverviewPresenter < Dragnet::View::Presenter
  presents User, as: :user

  def surveys = RecentActiveWorkspaceQuery.(user, Time.zone.now.end_of_day, limit: 6)

  def user_stats = StatsReport.new(user)
  memoize :user_stats

  def query_desc = RecentActiveWorkspaceQuery.query_doc

  def replies_by_date = RepliesByDateQuery.(user.survey_ids)

  def survey_count = user.surveys.count
  memoize :survey_count
end
