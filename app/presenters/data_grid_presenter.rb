# frozen_string_literal: true

# Presents surveys for the data grid
class DataGridPresenter < Dragnet::View::PagedPresenter
  presents Survey, as: :survey
  default_items 20

  delegate :id, to: :survey, prefix: :survey
  delegate :not_ready_for_replies?, :no_data?, to: :survey_presenter

  # @return [SurveyPresenter]
  def survey_presenter
    SurveyPresenter.new(survey)
  end
  memoize :survey_presenter

  # Replies sorted, filtered and paginated based on params
  #
  # @return [ActiveRecord::Relation<Reply>]
  def paginated_records
    records.offset(pager.offset).limit(pager.items)
  end
  memoize :paginated_records

  def records
    ordered_records(DataGridFilterQuery.(survey, params))
  end

  def ordered_records(scope)
    if !sort_by_question?
      scope.order(sort_by => sort_direction)
    else
      q = Question.includes(:question_type).find(params[:sort_by])
      sort_records(q, scope.joins(:answers).where(answers: { question_id: q.id }))
    end
  end

  def sort_records(question, scope)
    DataGridSortQueryPerspective.get(question.question_type).sort(question, scope, sort_direction)
  end

  def show_clear_filter?
    params[:filter_by].blank? || params[:filter_by].compact_blank.blank?
  end

  def show_load_more?
    pager.next && records.count > pager.items
  end

  # Pager object populated with record and parameter data.
  #
  # @return [Pagy]
  def pager = Pagy.new(count: survey.replies.count, page: page, items: items)
  memoize :pager

  # Return the field to sort the replies by, defaults to :created_at
  #
  # @return [Symbol]
  def sort_by
    params.fetch(:sort_by, :created_at).to_sym
  end
  alias sorted_by sort_by

  def sort_by_question? = uuid?(params[:sort_by])
  alias sorted_by_question? sort_by_question?

  # @param [Symbol, Question] column
  def sorted_by_column?(column)
    if sorted_by_question? && column.is_a?(Question)
      params[:sort_by] == column.id
    else
      sort_by == column
    end
  end

  # TODO: make this configurable
  def default_sort_direction = :desc

  def opposite_sort_direction
    sorted_ascending? ? :desc : :asc
  end

  def sorted_ascending?
    sort_direction == :asc
  end

  def sorted_descending?
    sort_direction == :desc
  end

  # Return the sort direction indicated by the symbols :asc or :desc ascending or descending respectively.
  #
  # @return [:asc, :desc]
  def sort_direction
    params.fetch(:sort_direction, default_sort_direction).to_sym
  end
end
