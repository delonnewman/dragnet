# frozen_string_literal: true

module Dragnet
  class DataGrid
    class QueryRelation
      include Dragnet
      include Memoizable

      delegate :sort_by, :sort_direction, :filter_by, :sort_by_question?, to: :@query
      delegate :to_sql, to: :build

      attr_reader :offset, :items

      def initialize(query, replies, offset: nil, items: nil)
        @query  = query
        @offset = offset
        @items  = items

        @base_relation = replies.includes(
          questions: %i[question_type question_options],
          answers:   { question: %i[question_type question_options] }
        )
      end

      # @return [ActiveRecord::Relation<Reply>]
      def build
        return records unless offset && items

        records.offset(offset).limit(items)
      end

      def records
        ordered_records(filtered_records(@base_relation))
      end
      memoize :records

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

      def ordered_records(scope)
        if !sort_by_question?
          scope.order(sort_by => sort_direction)
        else
          question = @query.question(sort_by)
          scope = sorting_scope(scope, question.id)
          join_name = join_aliases.fetch(:sorting, :answers)
          question.type.send_action(:sort_data_grid, question:, scope:, direction: sort_direction, join_name:)
        end
      end

      def sorting_scope(scope, question_id)
        if no_joins?
          scope.joins(:answers).where(answers: { question_id: })
        else
          join_name = next_join_alias
          join_aliases[:sorting] = join_name
          scope
            .joins(Arel.sql("inner join answers #{join_name} on replies.id = #{join_name}.reply_id"))
            .where(join_name => { question_id: })
        end
      end

      def filtered_records(scope)
        return scope unless @query.filtered?

        @query.filters.reduce(scope) do |current_scope, (field, value)|
          if @query.primitive_attribute?(field)
            current_scope.where(field => value)
          elsif @query.question?(field)
            join_name = join_alias(field)
            narrowed  = narrowed_scope(current_scope, field, join_name)
            filtered_values(narrowed, @query.question(field), join_name, value)
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
        question.type.send_action(:filter_data_grid, question:, relation: scope, table:, value:)
      end
    end
  end
end
