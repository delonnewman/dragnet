# frozen_string_literal: true

class OverviewPresenter < Dragnet::View::Presenter
  presents User, as: :user

  def surveys = RecentActiveWorkspaceQuery.(user, Time.zone.now.end_of_day, limit: 6)

  def query_desc = RecentActiveWorkspaceQuery.query_doc

  def replies_by_date = RepliesByDateQuery.(user.survey_ids)

  def survey_count = user.surveys.count
  memoize :survey_count
end
