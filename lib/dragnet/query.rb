# frozen_string_literal: true

module Dragnet
  class Query
    include Invokable
    extend ClassMetaData

    class << self
      # TODO: memoize?
      def connection
        MiniSql::Connection.get(ActiveRecord::Base.connection)
      end

      alias query_doc class_doc

      def query_text(text = nil)
        return @query_text unless text

        @query_text = text
      end
    end


    delegate :connection, to: :class

    def model_query(model_class, *params)
      query = query_text
      Rails.logger.info "SQL Query - #{query.inspect} #{params.inspect}"
      connection.query_hash(query, *params).map do |h|
        model_class.new(h)
      end
    end
    alias q model_query

    def query_text
      self.class.query_text.gsub(/\s+/, ' ')
    end

    def hash_query(*params)
      connection
        .query_hash(query_text, *params)
        .lazy.map { _1.transform_keys!(&:to_sym) }
    end
  end
end
