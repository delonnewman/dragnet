# frozen_string_literal: true

class SurveyListingPresenter < Dragnet::View::PagedPresenter
  presents User, as: :user
  default_items 7

  def surveys = user.surveys.order(updated_at: :desc).offset(pager.offset).limit(pager.items)
  memoize :surveys

  # @return [Pagy]
  def pager = Pagy.new(count: user.surveys.count, page: page, items: items)
  memoize :pager

  # @param [Survey] survey
  #
  # @return [Array<Integer>]
  def reply_counts_for(survey) = reply_counts.fetch(survey.id, EMPTY_HASH).values

  def reply_counts = RepliesBySurveyAndDateQuery.(user)
  memoize :reply_counts
end
