# frozen_string_literal: true

module Dragnet
  class Query < Composed
    include Invokable
    include Dragnet
    extend ClassMetaData

    class << self
      # TODO: memoize?
      def connection
        conn = ActiveRecord::Base.connection
        conn = conn.active? ? conn : ActiveRecord::Base.establish_connection

        MiniSql::Connection.get(conn)
      end

      alias query_doc class_doc

      def query_text(text = nil)
        return @query_text unless text

        @query_text = text
      end
    end

    delegate :connection, to: :class

    def model_query(model_class, *params)
      hash_query(*params).map do |h|
        model_class.new(h)
      end
    end
    alias q model_query

    def hash_query(*params)
      Rails.logger.info "SQL Query - #{query_text.inspect} #{params.inspect}"
      connection
        .query_hash(query_text, *params)
        .lazy.map { El::DataUtils.parse_nested_hash_keys(_1) }
    end

    def query_text
      @query_text ||= self.class.query_text.gsub(/\s+/, ' ')
    end
  end
end
