# frozen_string_literal: true

module Dragnet
  class Query
    include Invokable
    extend SelfDescribing

    class << self
      # TODO: memoize?
      def connection
        MiniSql::Connection.get(ActiveRecord::Base.connection)
      end

      alias query_doc class_doc
    end


    delegate :connection, to: :class

    def model_query(model_class, query, *params)
      Rails.logger.info "SQL Query - #{query.gsub(/\s+/, ' ').inspect} #{params.inspect}"
      connection.query_hash(query, *params).map do |h|
        model_class.new(h)
      end
    end

    alias q model_query
  end
end
