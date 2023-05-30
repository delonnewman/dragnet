# frozen_string_literal: true

# Presents surveys for the data grid
class DataGridPresenter < Dragnet::View::PagedPresenter
  presents Survey, as: :survey
  default_items 20

  delegate :id, to: :survey, prefix: :survey

  # Replies sorted, filtered and paginated based on params
  #
  # @return [ActiveRecord::Relation<Reply>]
  def paginated_records
    records.offset(pager.offset).limit(pager.items)
  end
  memoize :paginated_records

  def records
    ordered_records(filtered_records(survey.replies))
  end

  def ordered_records(scope)
    if not sort_by_question?
      scope.order(sort_by => sort_direction)
    else
      q = Question.includes(:question_type).find(params[:sort_by])
      t = q.question_type
      scope.joins(:answers).where(answers: { question_id: q.id }).order(t.answer_value_field => sort_direction)
    end
  end

  def filtered_records(scope)
    params = filter_params
    return scope if params.empty?

    question_ids = params.keys.select(&method(:uuid?))
    questions = question_ids.empty? ? EMPTY_HASH : Question.includes(:question_type).find(question_ids).group_by(&:id)


    params.to_h.reduce(scope) do |s, (k, v)|
      if uuid?(k)
        t = questions[k].first.question_type
        s.joins(:answers).where(answers: { question_id: k, t.answer_value_field => filter_value(t, v) })
      elsif k == :created_at || k == :user_id
        s.where(k => v)
      else
        s
      end
    end
  end

  def filter_value(question_type, value)
    value
  end

  def filter_params
    return EMPTY_HASH if params.empty? || params[:filter_by].blank?

    params[:filter_by]
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
      params[:sort_by] == column&.id
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
