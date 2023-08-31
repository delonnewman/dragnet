# frozen_string_literal: true

class Dragnet::DataGrid::FilteredRecords < Dragnet::Query
  SIMPLE_FILTER_ATTRIBUTES = %i[created_at user_id].to_set.freeze

  alias grid subject
  delegate :survey, to: :grid

  # @param [ActionController::Parameters, Hash] params
  #
  # @return [ActiveRecord::Relation]
  def call(params)
    scope = survey.replies
    return scope if params.empty? || params[:filter_by].blank?

    params = params[:filter_by].compact_blank
    filtered_records(scope, params)
  end

  private

  def filtered_records(scope, params)
    return scope if params.empty?

    question_ids = params.keys.select(&method(:uuid?))
    questions = question_ids.empty? ? EMPTY_HASH : Question.includes(:question_type).find(question_ids).group_by(&:id)

    join_name = +'answers'
    params.to_h.reduce(scope) do |s, (field, value)|
      if SIMPLE_FILTER_ATTRIBUTES.include?(field)
        s.where(field => value)
      elsif uuid?(field)
        q = questions[field].first
        scope =
          s.joins("inner join answers #{join_name} on replies.id = #{join_name}.reply_id")
           .where(join_name => { question_id: field })
        filter_value(scope, q, join_name, value).tap do
          join_name.succ!
        end
      else
        s
      end
    end
  end

  def filter_value(scope, question, table, value)
    Dragnet::Perspectives::DataGridFilterQuery.get(question.question_type).filter(question, scope, table, value)
  end
end
