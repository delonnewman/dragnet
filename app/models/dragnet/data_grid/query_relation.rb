# frozen_string_literal: true

module Dragnet
  class DataGrid
    class QueryRelation
      include Dragnet
      include Memoizable

      attr_reader :sort_by, :sort_direction, :filter_by

      def initialize(base_relation, params)
        @base_relation = base_relation
        @sort_by, @sort_direction, @filter_by =
          params.values_at(:sort_by, :sort_direction, :filter_by)
      end

      # @return [ActiveRecord::Relation<Reply>]
      def build
        ordered_records(filtered_records(@base_relation))
      end

      private

      attr_writer :join_alias_index

      def join_alias_index
        @join_alias_index ||= 0
      end

      def next_join_alias
        "answers_#{join_alias_index}".tap do
          self.join_alias_index += 1
        end
      end

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

      def sort_by_question?
        uuid?(sort_by)
      end

      def ordered_records(scope)
        if !sort_by_question?
          scope.order(sort_by => sort_direction)
        else
          question = Question.includes(:question_type).find(sort_by)
          sorted_records(question, sorting_scope(scope, question))
        end
      end

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

      def sorted_records(question, scope)
        question.type.data_grid_sort(question, scope, sort_direction, join_aliases.fetch(:sorting, :answers))
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
        question.type.data_grid_filter(question, scope, table, value)
      end
    end
  end
end
