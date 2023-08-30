# frozen_string_literal: true

# Provides data access and business rules for survey data grids
class DataGrid < ApplicationRecord
  # Surveys & Questions
  belongs_to :survey, inverse_of: :data_grids
  has_many :questions, through: :survey, inverse_of: :survey
  has_many :replies,   through: :survey, inverse_of: :survey

  belongs_to :user, inverse_of: :data_grids

  # RecordChanges
  has_many :record_changes, through: :survey, inverse_of: :survey
  delegate :record_changes?, to: :survey

  # Records, filtering & sorting
  with FilteredRecords, calling: :call

  # @param [Hash] params
  # @param [Symbol, String] sort_by
  # @param [:asc, :desc] sort_direction
  #
  # @return [ActiveRecord::Relation<Reply>]
  def records(sort_by:, sort_direction:, sort_by_question:, **params)
    ordered_records(
      filtered_records(params),
      sort_by:          sort_by,
      sort_by_question: sort_by_question,
      sort_direction:   sort_direction
    )
  end

  # @param [ActiveRecord::Relation] scope
  #
  # @return [ActiveRecord::Relation<Reply>]
  def ordered_records(scope, sort_by_question:, sort_by:, sort_direction:)
    if !sort_by_question
      scope.order(sort_by => sort_direction)
    else
      q = Question.includes(:question_type).find(sort_by)
      sorted_records(q, scope.joins(:answers).where(answers: { question_id: q.id }))
    end
  end

  # @param [Question] question
  # @param [ActiveRecord::Relation] scope
  #
  # @return [ActiveRecord::Relation]
  def sorted_records(question, scope)
    Dragnet::Perspectives::DataGridSortQuery.get(question.question_type).sort(question, scope, sort_direction)
  end
end
