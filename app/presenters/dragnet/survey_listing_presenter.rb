# frozen_string_literal: true

class Dragnet::SurveyListingPresenter < Dragnet::View::PagedPresenter
  presents Workspace, as: :space
  default_items 7

  delegate :user, to: :space

  def surveys = user.surveys.order(updated_at: :desc).offset(pager.offset).limit(pager.limit)
  memoize :surveys

  # @return [Pagy]
  def pager = Pagy.new(count: user.surveys.count, page:, limit: items)
  memoize :pager

  # Return reply data for the given survey
  #
  # @param [Survey] survey
  #
  # @return [Hash{String => Integer}]
  def reply_counts_for(survey) = reply_counts.fetch(survey.id, EMPTY_HASH).transform_keys { |d| "Replies on #{d}" }

  def reply_counts = space.replies_by_survey_and_date
  memoize :reply_counts

  def show_pagination?
    pager.count > pager.limit
  end
end
