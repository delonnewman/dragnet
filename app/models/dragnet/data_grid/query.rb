# frozen_string_literal: true

module Dragnet
  class DataGrid::Query
    include Dragnet
    include Memoizable

    PRIMATIVE_FILTER_ATTRIBUTES = %i[created_at user_id].to_set.freeze

    attr_reader :sort_by, :sort_direction, :filter_by, :questions
    alias filters filter_by
    alias sorted_by sort_by

    def initialize(questions, params, defaults = EMPTY_HASH)
      @questions = questions
      @sort_by = params[:sort_by] || defaults.fetch(:sort_by, :created_at)
      @sort_direction = params[:sort_direction] || defaults.fetch(:sort_direction, :desc)
      @filter_by = params[:filter_by] || defaults.fetch(:filter_by, EMPTY_HASH)
    end

    def relation(replies, **options)
      DataGrid::QueryRelation.new(self, replies, **options)
    end

    def sort_by_question?
      uuid?(sort_by)
    end
    alias sorted_by_question? sort_by_question?

    def filtered?
      !@filter_by.empty?
    end
    alias has_filters? filtered?

    def primative_attribute?(name)
      PRIMATIVE_FILTER_ATTRIBUTES.include?(name)
    end

    def question?(question_id)
      questions_map.key?(question_id)
    end

    def question(question_id)
      questions_map.fetch(question_id) do
        raise "unknown question as query value `#{question_id}`"
      end
    end

    # @return [Hash{String => Question}]
    def questions_map
      questions.index_by(&:id)
    end
    memoize :questions_map

    # @param [Symbol, Question] column
    def sorted_by_column?(column)
      return sort_by == column.id if sorted_by_question? && column.is_a?(Question)

      sort_by == column
    end

    def opposite_sort_direction
      sorted_ascending? ? :desc : :asc
    end

    def sorted_ascending?
      sort_direction == :asc
    end

    def sorted_descending?
      sort_direction == :desc
    end
  end
end
