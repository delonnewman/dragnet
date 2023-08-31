# frozen_string_literal: true

module Dragnet
  class DataGrid::Query
    include Dragnet
    include Memoizable

    attr_reader :survey
    attr_reader :params

    delegate :to_sql, to: :records

    def initialize(survey, params)
      @survey = survey
      @params = params.frozen? ? params : params.dup.freeze
    end

    def sort_by
      params.fetch(:sort_by, :created_at)
    end

    def sort_direction
      params.fetch(:sort_direction, :desc)
    end

    def filter_by
      params.fetch(:filter_by, EMPTY_HASH)
    end

    def sort_by_question?
      uuid?(sort_by)
    end

    # @return [Array<String>]
    def question_ids
      filter_by.keys.select { uuid?(_1) }
    end
    memoize :question_ids

    # @return [Array<Question>]
    def questions
      return EMPTY_ARRAY if question_ids.empty?

      Question.includes(:question_type).find(question_ids)
    end
    memoize :questions

    # @return [Hash{String => Question}]
    def questions_map
      questions.each_with_object({}) do |question, map|
        map[question.id] = question
      end
    end
    memoize :questions_map

    def question(question_id)
      questions_map.fetch(question_id) do
        raise "unknown question as query value `#{question_id}`"
      end
    end

    def question?(question_id)
      questions_map.key?(question_id)
    end

    attr_writer :join_alias_index

    def join_alias_index
      @join_alias_index ||= 0
    end

    def next_join_alias
      "answers_#{join_alias_index}".tap do
        self.join_alias_index += 1
      end
    end

    private :join_alias_index, :join_alias_index=, :next_join_alias

    def join_aliases
      filter_by.each_with_object({}) do |(field, _), aliases|
        aliases[field] = next_join_alias if uuid?(field)
      end
    end
    memoize :join_aliases

    def join_alias(question_id)
      join_aliases.fetch(question_id) do
        raise "unknown join alias for `#{question_id}`"
      end
    end

    def no_joins?
      join_aliases.count.zero?
    end

    # @return [ActiveRecord::Relation<Reply>]
    def records
      ordered_records(filtered_records(survey.replies))
    end

    private

    def sorting_scope(scope, question)
      if no_joins?
        scope.joins(:answers).where(answers: { question_id: question.id })
      else
        join_name = next_join_alias
        join_aliases[:sorting] = join_name
        scope
          .joins(Arel.sql("inner join answers #{join_name} on replies.id = #{join_name}.reply_id"))
          .where(join_name => { question_id: question.id })
      end
    end

    def ordered_records(scope)
      if !sort_by_question?
        scope.order(sort_by => sort_direction)
      else
        question = Question.includes(:question_type).find(sort_by)
        sorted_records(question, sorting_scope(scope, question))
      end
    end

    def sorted_records(question, scope)
      Perspectives::DataGridSortQuery
        .get(question.question_type)
        .sort(question, scope, sort_direction, join_aliases.fetch(:sorting, :answers))
    end

    SIMPLE_FILTER_ATTRIBUTES = %i[created_at user_id].to_set.freeze
    private_constant :SIMPLE_FILTER_ATTRIBUTES

    def filtered_records(scope)
      return scope if filter_by.empty?

      filter_by.reduce(scope) do |current_scope, (field, value)|
        if SIMPLE_FILTER_ATTRIBUTES.include?(field)
          current_scope.where(field => value)
        elsif question?(field)
          join_name = join_alias(field)
          narrowed  = narrowed_scope(current_scope, field, join_name)
          filtered_values(narrowed, question(field), join_name, value)
        else
          current_scope
        end
      end
    end

    def narrowed_scope(scope, field, join_name)
      scope
        .joins(Arel.sql("inner join answers #{join_name} on replies.id = #{join_name}.reply_id"))
        .where(join_name => { question_id: field })
    end

    def filtered_values(scope, question, table, value)
      Perspectives::DataGridFilterQuery.get(question.question_type).filter(question, scope, table, value)
    end
  end
end