# frozen_string_literal: true

# Presents surveys for the data grid
class Dragnet::DataGridPresenter < Dragnet::View::PagedPresenter
  presents DataGrid, as: :grid
  default_items 20

  delegate :survey, to: :grid
  delegate :id, :name, to: :survey, prefix: :survey
  delegate :not_ready_for_replies?, :no_data?, to: :survey_presenter
  delegate :filter_by, :sort_by, :sort_by_question?, to: :query
  delegate :sorted_by_column?, :opposite_sort_direction, :sorted_ascending?, :sorted_descending?, to: :query

  # @return [SurveyPresenter]
  def survey_presenter
    SurveyPresenter.new(survey)
  end
  memoize :survey_presenter

  def questions
    survey.questions.map(&:present)
  end

  def to_h
    record_data = records.pull(
      :id,
      :created_at,
      :updated_at,
      answers: %i[
        id
        question
        question_option_id
        text_value
        number_value
        time_value
        date_value
        boolean_value
      ]
    )

    {
      id: survey.id,
      name: survey.name,
      records: record_data,
      offset: pager.offset,
      items: pager.in,
    }
  end

  def records
    relation.build
  end
  memoize :records

  def record_count
    relation.records.count
  end
  memoize :record_count

  def relation
    query.relation(survey.replies, offset: pager.offset, items: pager.in)
  end
  memoize :relation

  def show_clear_filter?
    query.filtered?
  end

  def query
    grid.query(
      sort_by:        params[:sort_by].presence,
      sort_direction: params[:sort_direction].presence,
      filter_by:      params[:filter_by].presence
    )
  end
  memoize :query

  def show_load_more?
    pager.next && record_count > pager.items
  end

  # Pager object populated with record and parameter data.
  #
  # @return [Pagy]
  def pager = Pagy.new(count: survey.replies.count, page:, limit: items)
  memoize :pager
end
