# frozen_string_literal: true

# Presents surveys for the data grid
class DataGridPresenter < Dragnet::View::PagedPresenter
  presents Survey, as: :survey

  # @return [ActiveRecord::Relation<Reply>]
  def paginated_records
    scope = survey.replies

    scope = if sort_by_question?
              scope.joins(:answers).where(answers: { question_id: params[:sort_by] }).order(sort_value: sort_direction)
            else
              scope.order(sort_by => sort_direction)
            end

    scope.offset(pager.offset).limit(pager.items)
  end
  memoize :paginated_records

  # @return [Pagy]
  def pager = Pagy.new(count: survey.replies.count, page: page, items: items)
  memoize :pager

  # Return the field to sort the replies by, defaults to :created_at
  #
  # @return [Symbol]
  def sort_by
    params.fetch(:sort_by, :created_at).to_sym
  end

  def sort_by_question?
    uuid?(params[:sort_by])
  end

  def sort_direction
    params.fetch(:sort_direction, :desc)
  end
end
