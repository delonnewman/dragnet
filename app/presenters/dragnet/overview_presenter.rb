# frozen_string_literal: true

class Dragnet::OverviewPresenter < Dragnet::View::Presenter
  presents Workspace, as: :space

  delegate :replies_by_date, to: :space

  def surveys = space.recently_active_surveys(last_created: Time.zone.now.end_of_day, limit: 8)

  def stats = StatsReport.new(space)
  memoize :stats

  def survey_count = user.surveys.count
  memoize :survey_count
end
