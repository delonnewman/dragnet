# frozen_string_literal: true

# Presents surveys for the data grid
class DataGridPresenter < Dragnet::View::PagedPresenter
  presents Survey, as: :survey

  # @return [ActiveRecord::Relation<Reply>]
  def paginated_records = survey.replies.order(:created_at).offset(pager.offset).limit(pager.items)
  memoize :paginated_records

  # @return [Pagy]
  def pager = Pagy.new(count: survey.replies.count, page: page, items: items)
  memoize :pager
end
