# frozen_string_literal: true

class OverviewPresenter < Dragnet::View::Presenter
  presents User, as: :user

  def surveys = RecentlyRepliedToQuery.(user, limit: 6)

  def query_desc = RecentlyRepliedToQuery.query_doc

  def replies_by_date = RepliesByDateQuery.(user.survey_ids)

  def survey_count = user.surveys.count
  memoize :survey_count
end
