# frozen_string_literal: true

module Dragnet
  class DataGrid::Query
    include Dragnet
    include Memoizable

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
      questions.index_by(&:id)
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

    # @return [ActiveRecord::Relation<Reply>]
    def records
      relation.build
    end

    private

    def relation
      DataGrid::QueryRelation.new(base_relation, sort_by:, sort_direction:, filter_by:)
    end
    memoize :relation

    def base_relation
      @survey.replies.includes(questions: %i[question_type question_options], answers: { question: %i[question_type question_options] })
    end
  end
end
